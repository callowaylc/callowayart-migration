#!/usr/bin/env ruby
# callowaylc@gmail.com
# Migrates old callowayart to new database

desc "Fix domain issues from vendor"
task :replace_domain, [:domain] do |t, args|
  find = "dev.brandefined.net"
  replace = {
    "http://dev.brandefined.net" => "https://" + args[:domain],
    "dev.brandefined.net" => args[:domain],
    "wdp-103964-susan-calloway/" => "",
    "wdp-103964-susan-calloway" => "",
  }

  # replace all occurrences of dev.brandefined in wp_options
  results = query "wordpress", %{
    select option_id, option_value from wp_options where option_value like "%#{ find }%"
  }

  results.each do | result |
    replace.each do | finds, with |
      result["option_value"].gsub! finds, with
    end

    statement = client("wordpress").prepare %{
      update wp_options set option_value=? WHERE option_id=?
    }
    statement.execute(result["option_value"], result["option_id"])
  end
end

# methods #######################################

private def query database, sql, arguments=nil
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
  rescue => _
    logs "failed query", query: sql
  end
  result.each unless result.nil?
end

private def client database
  @database ||= { }
  @database[database] ||= begin
    Mysql2::Client.new(
      host: 'db',
      user: 'root',
      password: 'wordpress',
      database: database
    )
  end
end