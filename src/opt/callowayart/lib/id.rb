#!/usr/bin/env ruby
def id string
  ( string.match /post=(?<id>[0-9]+)/ )[:id]
end
