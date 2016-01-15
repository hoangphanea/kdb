require 'capybara'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = "http://www.masokaraoke.net"
