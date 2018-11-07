require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless
                              disable-gpu
                              no-sandbox
                              disable-dev-shm-usage
                              disable-software-rasterizer] }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
end
