#!/usr/bin/env ruby
def login
  include Capybara::DSL

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome, prefs: {
      download: {
        default_directory: '/tmp/callowayart-migration'
      }
    })
  end
  Capybara.javascript_driver = :selenium
  Capybara.run_server = false
  Capybara.current_driver = :selenium

  visit 'http://migrated.callowayart.com/wp-admin'
  fill_in :log, with: config['callowayart']['user']
  fill_in :pwd, with: config['callowayart']['password']
  click_button 'wp-submit'
end