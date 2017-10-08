#!/usr/bin/env ruby
# callowaylc@gmail
# Bootstraps required libraries or configuration

require 'mysql2'
require 'yaml'
require 'slugify'
require 'json'
require 'logger'

class String
  alias_method :old_slug, :slugify

  def slugify
    old_slug.gsub /-{2,}/, '-'
  end
end
