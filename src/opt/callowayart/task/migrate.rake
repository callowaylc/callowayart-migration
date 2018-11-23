#!/usr/bin/env ruby
# callowaylc@gmail.com
# Migrates old callowayart to new database

CONTEMPORARY_TERM_TAXONOMY_ID = 8
EXHIBIT_CURRENT_TERMTAX_ID = 4
EXHIBIT_PAST_TERMTAX_ID = 5
EXHIBIT_UPCOMINGTAX_TERM_ID = 6


desc "migrate to new callowayart"
task :migrate do

  # get all works
  listings = [ ]
  limit = ( ENV["MIGRATION_LIMIT"] || 100 ).to_i
  limit = 1000000 if limit == -1
  posts    = query 'callowayart', %{
    SELECT
      ID as id,
      post_content as content,
      TRIM(post_title) as title,
      guid as uri
    FROM wp_posts wp
    WHERE
      wp.post_type   = "attachment" AND
      wp.post_status = "inherit"
    ORDER BY wp.post_modified DESC
    LIMIT #{ limit }
  }
  counter = 0

  posts.each do | listing |
    logs 'process listing', payload: listing
    listing['artists'] = [ ]
    listing['exhibits'] = [ ]
    listing['categories'] = [ ]

    begin
      raise :shit unless %x{
        curl -m5 -I #{ listing['uri'] } -w '%{response_code}' -so /dev/null
      } =~ /200/

    rescue
      meta = query 'callowayart', %{
        SELECT
          meta_value
        FROM
          wp_postmeta
        WHERE
          meta_key = 'amazonS3_info' AND
          post_id = #{ listing['id'] }
      }

      unless meta.empty?
        listing['uri'] = 'http://callowayart-com.s3.amazonaws.com/' +
          meta[0]['meta_value'].match(
            /(?<resource>wp-content.+)\"/
          )[:resource]
      end
    end

    listings << begin
      # get listing categories
      listing['categories'] = query 'callowayart', %{
        SELECT
          wpt.slug,
          wpt.term_id as id
        FROM wp_terms wpt
          INNER JOIN wp_term_taxonomy wptt
            ON ( wpt.term_id = wptt.term_id )
          INNER JOIN wp_term_relationships wptr
            ON ( wptt.term_taxonomy_id = wptr.term_taxonomy_id )
        WHERE
          wptr.object_id = '#{ listing['id'] }' AND
          wptt.taxonomy = 'media_tag'
      }

      # get artist/exhibit iterating through terms
      ( query 'callowayart', %{
        SELECT
          wpt.term_id as id,
          wpt.slug,
          wptt.parent as parent_id
        FROM wp_terms wpt
          INNER JOIN wp_term_taxonomy wptt
            ON wpt.term_id = wptt.term_id
          INNER JOIN wp_term_relationships wptr
            ON ( wptr.term_taxonomy_id = wptt.term_taxonomy_id )
        WHERE
          wptr.object_id = #{ listing['id'] }

      } ).each do | term |
        ( query 'callowayart', %{
          SELECT
            description
          FROM wp_term_taxonomy wptt
            INNER JOIN wp_terms wpt
              ON ( wpt.term_id = wptt.parent )
          WHERE
            wptt.term_id = #{ term['id'] } AND
            wpt.slug = 'artist'
        } ).each do | tax |
          listing['artists'] ||= [ ]
          listing['artists'] << {
            'slug' => term['slug'],
            'description' => tax['description']
          }
        end

        ( query 'callowayart', %{
          SELECT
            description
          FROM wp_term_taxonomy wptt
            INNER JOIN wp_terms wpt
              ON ( wpt.term_id = wptt.parent )
          WHERE
            wptt.term_id = #{ term['id'] } AND
            wpt.slug = 'exhibit'
        } ).each do | tax |
          # add artist to something..
          listing['exhibits'] ||= [ ]
          listing['exhibits'] << {
            'slug' => term['slug'],
            'description' => tax['description']
          }
        end
      end

      listing['categories'] = listing['categories'].delete_if do | category |
        found = false

        listing['artists'].each do | artist |
          if artist['slug'] == category['slug']
            found = true
            break
          end
        end

        listing['exhibits'].each do | exhibit |
          if exhibit['slug'] == category['slug']
            found = true
            break
          end
        end

        found
      end

      {
        /\$/ => 'price',
        /(oil|pain|canvas|mono|paper|mixed|media|acrylic|porcelain|bronze|gold|wood|board|plate|color)/i => 'media',
        /(x|')/ => 'size',
        /[CIS][0-9]{4}/i => 'inventory_id'

      }.each do | expression, type |
        ( listing['content'].split /[\r\n]+/ ).last( 4 ).each do | line |
          if expression =~ line
            listing[type] = ( line.gsub /^.+\:/, '' ).sub /\$/, ''
            break
          end
        end
      end

      if listing['size']
        listing['size'] = sanitize listing['size']
      end

      # price needs some additional massaging
      if listing['price']
        begin
          listing['price'] = (
            listing['price'].match( /^.+?(?<number>[0-9,]+)/ )['number']
          ).sub /,/, ''
        rescue
        end
      end

      if listing['inventory_id']
        listing['inventory_id'] = ( listing['inventory_id'].match /[CIS][0-9]{4}([a-z]{2})?/i )[0]
      end

      # check what listing fields are missing and write to log
      listing.each do | key, value |
        if listing[key].nil?
          logs "failed to find listing attribute", {
            name: key,
            id: listing['id'],
            slug: listing['slug']
          }
        end
      end
      listing
    end
  end

  artists( listings ).each do | slug, artist |
    artist = insert_artist artist
    seen = { }
    backend = true

    # insert artist listingss
    unless artist['listings'].empty?
      artist['listings'].each do | listing |
        seen[listing['title'].slugify] ||= begin
          listing = insert_work artist, listing
        end
      end

      unless artist["categories"].none? { | c | c["slug"] =~ /backend/i }
        wp_codex(`
          ./bin/hide-post #{ artist['id'] }
        `)
      end

      # set thumbnail id for artist
      listing = artist['listings'].first
      artist['thumbnail_id'] = listing['thumbnail_id']

      query 'wordpress', %{
        UPDATE wp_postmeta
        SET meta_value = '#{ listing['thumbnail_id'] }'
        WHERE
          meta_key = '_thumbnail_id' AND
          post_id = #{ artist['id'] }
      }
      logs "inserted thumbnail id", thumbnail: listing["thumbnail_id"]

    end

    # insert artist exhibits
    seen = { }
    unless artist['exhibits'].empty?
      artist['exhibits'].each do | exhibit |
        listing = artist['listings'].find do | listing |
          listing['exhibits'].any? do | compare |
            compare['slug'] == exhibit['slug']
          end
        end

        seen[exhibit['slug']] ||= begin
          exhibit = insert_exhibit artist, listing, exhibit
        end
      end
    end

  end

  # dump migration database, convert to utf8, and reimport
  logs "force utf8 conversion and reimport"
  command %{
    export MYSQL_PWD=wordpress
    mysqldump \
      -hdb \
      -uroot \
      --opt \
      --skip-set-charset \
      --default-character-set=latin1 \
      --skip-extended-insert \
        wordpress > /tmp/database.sql

    sed -i s/latin1/utf8/gI /tmp/database.sql
    #cat /tmp/database.sql | mysql \
    #  -h10.0.0.177 \
    #  -uroot \
    #  -Dwordpress
    #rm /tmp/database.sql
  }
end


# methods #######################################

private def query database, sql
  @database ||= { }
  @database[database] ||= begin
    Mysql2::Client.new(
      host: 'db',
      user: 'root',
      password: 'wordpress',
      database: database
    )
  end

  begin
    result = @database[database].query sql
  rescue => e
    logs "failed query", query: sql, error: e
  end
  result.each unless result.nil?
end

private def artists listings
  logs 'converting listings to artists'
  artists = { }

  listings.each do | listing |
    if listing['artists']
      logs "looking at categories", listing: listing, grep: "looking-at-categories"

      listing['artists'].each do | artist |
        slug = artist['slug']
        artists[slug] ||= {
          'description' => artist['description'],
          'slug' => slug,
          'listings' => [ ],
          'exhibits' => [ ],
          'categories' => listing["categories"],
        }
        artists[slug]['listings'] << listing

        if listing['exhibits']
          listing['exhibits'].each do | exhibit |
            artists[slug]['exhibits'] << exhibit
          end
        end
      end
    end
  end

  artists
end

private def insert_work artist, listing
  logs 'insert work', slug: listing['title'], artist: artist

  begin
    listing['thumbnail_id'] = wp_codex(`
      ./bin/post '#{ listing['uri'] }'
    `)
    listing['thumbnail_id'] = listing['thumbnail_id'].to_i
  rescue _
    listing['_thumbnail_id'] = 0
  end

  logs "thumbnail id", uri: listing["uri"], thumbnail: listing["thumbnail_id"], grep: "add-thumbnail"


  # insert descriptive post
  query 'wordpress', %{
    INSERT INTO
      wp_posts(
        post_author,
        post_date,
        post_date_gmt,
        post_modified,
        post_modified_gmt,
        post_excerpt,
        to_ping,
        pinged,
        post_content_filtered,
        post_content,
        post_title,
        post_password,
        post_name,
        guid,
        post_type

      ) values (
        1,
        now(),
        now(),
        now(),
        now(),
        '',
        '',
        '',
        '',
        '',
        "#{ sanitize listing['title'] }",
        "",
        "#{ artist['slug'] }-#{ listing['title'].slugify }",
        "/#{ artist['slug'] }/#{ listing['title'].slugify }",
        "works"
      )
  }

  listing['id'] = (
    query "wordpress", "select last_insert_id() as last_insert_id"
  )[0]['last_insert_id']

  {
    _thumbnail_id: listing['thumbnail_id'],
    _edit_last: 1,
    _edit_lock: '1470885356:3',
    :'works-artist' => artist['id'],
    :'_works-artist' => 'field_56deeff321416',
    :'works-media-type' => listing['media'],
    :'_works-media-type' => 'field_56def0e021417',
    :'works-price' => listing['price'],
    :'_works-price' => 'field_56def14d21418',
    :'works-size' => listing['size'],
    :'_works-size' => 'field_56df2554708e5',
    :'works-inventory' => listing['inventory_id'],
    :'_works-inventory' => 'field_58477d69efc86',
    :'eg-artist' => deslug( artist['slug'] )

  }.each do | field, value |
    query "wordpress", %{
      INSERT INTO wp_postmeta (
        post_id, meta_key, meta_value
      ) values (
        #{ listing['id'] }, '#{ field }', '#{ value }'
      )
    }
  end

  # create categories
  $categories ||= { }
  listing['categories'].each do | category |
    $categories[category['slug']] ||= begin

      exists = query 'wordpress', %{
        SELECT wpt.term_id
        FROM wp_terms wpt
          INNER JOIN wp_term_taxonomy wptt
            ON wptt.term_id = wpt.term_id
        WHERE
          wpt.slug = "#{ category['slug'] }" AND
          wptt.taxonomy = "category"
      }

      logs 'category exists?', slug:category['slug'], exists: !exists.empty?
      if exists.empty?
        logs 'create category', slug: category['slug'], empty: exists.nil?
        id = wp_codex(`
          ./bin/create-category "#{ deslug category['slug'] }"
        `)
      else
        id = exists.first['term_id']
      end

      logs 'retrieve category', slug: category['slug'], id: id
      result = query 'wordpress', %{
        SELECT term_taxonomy_id
        FROM wp_term_taxonomy
        WHERE term_id = #{ id }
      }

      if result.empty?
        query 'wordpress', %{
          INSERT INTO wp_term_taxonomy(
            term_id, taxonomy, description
          ) values (
            #{ id }, 'category', 'desc'
          )
        }

        term_taxonomy_id = (
          query "wordpress", "select last_insert_id() as last_insert_id"
        )[0]['last_insert_id']
      else
        query 'wordpress', %{
          update wp_term_taxonomy
          set taxonomy = 'category'
          where term_taxonomy_id = #{ result.first['term_taxonomy_id'] }
        }
        term_taxonomy_id = result.first['term_taxonomy_id']
      end

      query "wordpress", %{
        INSERT INTO wp_term_relationships(
          term_taxonomy_id, object_id
        ) values (
          #{ term_taxonomy_id }, #{ listing['id'] }
        )
      }

      # check if artist has been inserted, and if not
      # insert
      result = query "wordpress", %{
        SELECT 1
        FROM wp_term_relationships
        WHERE
          term_taxonomy_id = #{ term_taxonomy_id } AND
          object_id = #{ artist["id"] }
      }

      if result.empty?
        query "wordpress", %{
          INSERT INTO wp_term_relationships(
            term_taxonomy_id, object_id
          ) values (
            #{ term_taxonomy_id }, #{ artist["id"] }
          )
        }
      end
    end

    # finally, if category is backendonly, set post_status
    # to private
    if category['slug'] =~ /backend/i
      wp_codex(`
        ./bin/hide-post #{ listing['id'] }
      `)
    end
  end

  # look for contemporary in categories; if the case
  # we need to add listing and artist to contemporary
  if listing["categories"].any? { | c | c["slug"] =~ /contemporary/i }

    result = query "wordpress", %{
      SELECT 1
      FROM wp_term_relationships
      WHERE
        term_taxonomy_id = #{ CONTEMPORARY_TERM_TAXONOMY_ID } AND
        object_id = #{ listing["id"] }
    }
    if result.empty?
      logs "inserting listing into contemporary", grep: "inserting-listing-into-contemporary"

      query "wordpress", %{
        INSERT INTO wp_term_relationships(
          term_taxonomy_id, object_id
        ) values (
          #{ CONTEMPORARY_TERM_TAXONOMY_ID }, #{ listing["id"] }
        )
      }
    end

    # check if artist has been inserted, and if not
    # insert
    result = query "wordpress", %{
      SELECT 1
      FROM wp_term_relationships
      WHERE
        term_taxonomy_id = #{ CONTEMPORARY_TERM_TAXONOMY_ID } AND
        object_id = #{ artist["id"] }
    }

    if result.empty?
      logs "inserting artist into contemporary", grep: "inserting-artist-into-contemporary"

      query "wordpress", %{
        INSERT INTO wp_term_relationships(
          term_taxonomy_id, object_id
        ) values (
          #{ CONTEMPORARY_TERM_TAXONOMY_ID }, #{ artist["id"] }
        )
      }
    end
  end

  listing
end

private def sanitize value
  value = value.gsub /'/, ""
  value.to_ascii
end

private def insert_exhibit artist, listing, exhibit
  logs 'insert exhibit', payload: exhibit
  query 'wordpress', %{
    INSERT INTO
      wp_posts(
        post_author,
        post_date,
        post_date_gmt,
        post_modified,
        post_modified_gmt,
        post_excerpt,
        to_ping,
        pinged,
        post_content_filtered,
        post_content,
        post_title,
        post_password,
        post_name,
        guid,
        post_type

      ) values (
        1,
        now(),
        now(),
        now(),
        now(),
        '',
        '',
        '',
        '',
        '#{ sanitize exhibit['description'] }',
        "#{ deslug exhibit['slug'] }",
        "",
        "#{ exhibit['slug'] }",
        "_",
        "exhibitions"
      )
  }

  exhibit['id'] = (
    query "wordpress", "select last_insert_id() as last_insert_id"
  )[0]['last_insert_id']

  {
    exhibition_add_artists_0_exhibition_artist_name: deslug( artist['slug'] ),
    _exhibition_add_artists_0_exhibition_artist_name: 'field_570e70d57e3ba',
    exhibition_add_artists: 1,
    _exhibition_add_artists: 'field_570e70977e3b9',
    exhibition_opening_date: '20160921',
    _exhibition_opening_date: 'field_570eba7ed566b',
    exhibition_end_date: '20170910',
    _exhibition_end_date: 'field_570ebaf5d566c',
    _thumbnail_id: listing['thumbnail_id'] || 0

  }.each do | field, value |
    query "wordpress", %{
      INSERT INTO wp_postmeta (
        post_id, meta_key, meta_value
      ) values (
        #{ exhibit['id'] }, '#{ field }', '#{ value }'
      )
    }
  end

  # insert into wp_terms, wp_term_taxonomy
  query "wordpress", %{
    INSERT INTO
      wp_term_relationships (
        object_id, term_taxonomy_id
      )
      values (
        #{ exhibit['id'] }, #{ EXHIBIT_PAST_TERMTAX_ID }
      )
  }
  term_id = (
    query "wordpress", "select last_insert_id() as last_insert_id"
  )[0]['last_insert_id']


end

private def insert_artist artist
  logs 'insert artist', slug: artist['slug'], description: artist['description'].to_ascii

  result = query "wordpress", %{
    SELECT ID
    FROM wp_posts
    WHERE
      post_type = 'artist' AND
      post_name = '#{ artist["slug"] }'
  }

  unless result.empty?
    artist["id"] = result.first["ID"]
  else
    query 'wordpress', %{
      INSERT INTO
        wp_posts(
          post_author,
          post_date,
          post_date_gmt,
          post_modified,
          post_modified_gmt,
          post_excerpt,
          to_ping,
          pinged,
          post_content_filtered,
          post_content,
          post_title,
          post_password,
          post_name,
          guid,
          post_type

        ) values (
          1,
          now(),
          now(),
          now(),
          now(),
          '',
          '',
          '',
          '',
          '[et_pb_section admin_label="section"]
           [et_pb_row admin_label="row"]
           [et_pb_column type="4_4"]
           [et_pb_text admin_label="Text"]
            #{ sanitize artist['description'] }
           [/et_pb_text][/et_pb_column][/et_pb_row][/et_pb_section]',
          "#{ deslug artist['slug'] }",
          "",
          "#{ artist['slug'] }",
          "#{ artist['slug'] }",
          "artist"
        )
    }

    artist['id'] = (
      query "wordpress", "select last_insert_id() as last_insert_id"
    )[0]['last_insert_id']
  end

  {
    last_name: artist["slug"].split("-").last,
    _last_name: "field_59b06b1cf04ab",
    _edit_last: 1,
    _edit_lock: '1470716055:3',
    _thumbnail_id: 279,
    eg_sources_html5_mp4: nil,
    eg_sources_html5_ogv: nil,
    eg_sources_html5_webm: nil,
    eg_sources_youtube: nil,
    eg_sources_vimeo: nil,
    eg_sources_wistia: nil,
    eg_sources_image: nil,
    eg_sources_iframe: nil,
    eg_sources_soundcloud: nil,
    eg_vimeo_ratio: 0,
    eg_youtube_ratio: 0,
    eg_wistia_ratio: 0,
    eg_html5_ratio: 0,
    eg_soundcloud_ratio: 0,
    eg_settings_custom_meta_skin: nil,
    eg_settings_custom_meta_element: nil,
    eg_settings_custom_meta_setting: nil,
    eg_settings_custom_meta_style: nil,
    _et_pb_post_hide_nav: 'default',
    _et_pb_page_layout: 'et_full_width_page',
    _et_pb_side_nav: 'off',
    _et_pb_use_builder: 'on',
    _et_pb_old_content: "
      <div class=\"side-description\">#{ sanitize artist['description'] }</div>
    "

  }.each do | field, value |
    query "wordpress", %{
      INSERT INTO wp_postmeta (
        post_id, meta_key, meta_value
      ) values (
        #{ artist['id'] }, '#{ field }', '#{ value }'
      )
    }
  end

  query "wordpress", %{
    INSERT INTO
      wp_term_relationships (
        object_id, term_taxonomy_id
      )
      values (
        #{ artist['id'] }, 1
      )
  }

  artist
end

def wp_codex( result )
  begin
    Integer( result )
  rescue
    0
  end
end


