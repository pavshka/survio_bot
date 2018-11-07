require 'capybara'
require_relative 'chrome_headless'

class Worker
  def initialize
    @session = Capybara::Session.new(:selenium_chrome_headless).tap do |session|
      session.visit 'http://surviv.io/'
      puts 'Running capybara worker'
    end
  end

  def create_lobby
    puts 'Creating lobby'
    @session.find('#btn-create-team').click
    @session.find('#btn-team-fill-none').click
    @session.find('#team-url').text
  end

  def wait_for_other_players
    puts 'Waiting for other players'
    time_to_wait = 60

    while time_to_wait > 0
      sleep 2
      time_to_wait -= 2
      unless @session.find('#team-menu-member-list .team-menu-member:nth-child(2) .name').text.empty?
        time_to_wait = 0
      end
    end

    puts 'Leaving the lobby'
    @session.find('#btn-team-leave').click
  end
end
