require 'capybara'
# require_relative 'chrome_headless'

class Worker
  def initialize
    @session = Capybara::Session.new(:selenium_chrome)
    @session.visit 'http://surviv.io/'
  end

  def create_lobby
    create_team
    fill_none
    extract_team_url
  end

  def wait_for_other_players
    time_to_wait = 60
    delay = 2

    (time_to_wait / delay).times do
      return true if other_player_joined?

      sleep delay
    end

    false
  end

  def leave_lobby
    @session.find('#btn-team-leave').click
  end

  private

  def create_team
    @session.find('#btn-create-team').click
  end

  def fill_none
    @session.find('#btn-team-fill-none').click
  end

  def extract_team_url
    @session.find('#team-url').text
  end

  def other_player_joined?
    other_player = @session.find('#team-menu-member-list .team-menu-member:nth-child(2) .name').text
    !other_player.empty?
  end
end
