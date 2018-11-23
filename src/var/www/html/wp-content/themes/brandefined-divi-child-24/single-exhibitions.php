  <?php
  get_header();
  $is_page_builder_used = true;
  ?>
  <div id="main-content">
  <?php if ( ! $is_page_builder_used ) : ?>
    <div class="container">
      <div id="content-area" class="clearfix">
        <div id="left-area">
        <?php endif; ?>
        <?php while ( have_posts() ) : the_post(); ?>
          <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
          <?php if ( ! $is_page_builder_used ) : ?>
            <h1 class="entry-title main_title"><?php the_title(); ?></h1>
          <?php endif; ?>
            <div class="entry-content">
              <?php
                $opening_date  = get_field('exhibition_opening_date');
                $end_date  = get_field('exhibition_end_date');
                $gallery_images  = get_field('exhibition_gallery');
                $artist_array = get_field('exhibition_add_artists');
                $content = get_the_content('');
                $title  = get_the_title();

                $ex_opening_date = date('M jS, Y', strtotime($opening_date));
                $ex_end_date = date('M jS, Y', strtotime($end_date));

              ?>
              <div id="exhibition-single">
                <div class="et_pb_row">
                  <div class="bd-grid bd-vertical-center">
                    <div class="bd-row">
                      <div class="bd-col col-2-3">
                        <?php the_post_thumbnail('large'); ?>
                      </div>
                      <div class="bd-col col-1-3">
                        <?php if(function_exists('pf_show_link')){echo pf_show_link();} ?>

                        <div id="exhibition-info">
                          <h2><?php echo $title; ?></h2>
                          <h3>
                            <?php
                              if(get_field('exhibition_add_artists')):
                                while(has_sub_field('exhibition_add_artists')):
                                  echo the_sub_field('exhibition_artist_name')."<br>";
                                endwhile;
                              endif; ?>
                          </h3>
                          <p><?php echo $content; ?></p>
                          <p><strong>Opening date:</strong> <?php echo $ex_opening_date; ?></p>
                          <p><strong>Closing date:</strong> <?php echo $ex_end_date; ?></p>
                        </div>
                      </div>
                    </div>
                    <br>
                    <?php  if( $gallery_images ): ?>
                    <br>
                    <div class="more-exhibitions-works">
                        <div id="works-info" class="bd-grid">
                          <h3 class="more-by">More works</h3>
                          <div class="bd-row">
                             <?php foreach( $gallery_images as $image ): ?>
                              <div class="bd-col col-1-5">
                                <a href="<?php echo $image['url']; ?>" rel="lightbox[galeryex]">
                                          <img src="<?php echo $image['sizes']['thumbnail']; ?>" alt="<?php echo $image['alt']; ?>" />
                                        </a>
                              </div>
                                <?php endforeach; ?>
                            </div>
                        </div><!-- .bd-grid -->
                    </div>
                    <?php endif; ?>
                  </div><!-- .bd-grid -->
                </div><!-- .works-row -->
              </div>

            </div> <!-- .entry-content -->
          </article> <!-- .et_pb_post -->
        <?php endwhile; ?>
        <?php if ( ! $is_page_builder_used ) : ?>
        </div> <!-- #left-area -->
        <?php get_sidebar(); ?>
      </div> <!-- #content-area -->
    </div> <!-- .container -->
  <?php endif; ?>
  </div> <!-- #main-content -->
  <?php get_footer(); ?>