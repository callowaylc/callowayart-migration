#!/usr/bin/env ruby
def logs message, optional = { }
  @logger ||= Logger.new STDOUT
  entry = {
    message: message,
    timestamp: Time.new
  }.merge( optional )

  @logger.info entry.to_json
end
