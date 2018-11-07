require 'capybara'

class Worker
  def initialize
    @session = Capybara::Session.new(:selenium_chrome).tap do |session|
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
    wait_time = 60

    while wait_time > 0
      sleep 2
      wait_time -= 2
      unless @session.find('#team-menu-member-list .team-menu-member:nth-child(2) .name').text.empty?
        wait_time 0
      end
    end

    puts 'Leaving the lobby'
    @session.find('#btn-team-leave').click
  end
end
