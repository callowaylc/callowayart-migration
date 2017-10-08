#!/usr/bin/env ruby

def deslug slug
  ( slug.gsub /-/, ' ').split.map(&:capitalize).join(' ')
end