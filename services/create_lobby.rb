require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative '../lib/logging'

module Services
  class CreateLobby
    BASE_URL = 'http://surviv.io/'.freeze
    WEB_SOCKET_URL = 'ws://surviv.io/team'.freeze
    # Server sends keepAlive command every 1min 30sec, so after 3 keepAlive messages(4min 30sec)
    # connection would be closed
    KEEP_ALIVE_TIMEOUT = 3
    include Logging

    def self.call(recipient:, region: 'eu', team_size: 4, fill: false)
      new(recipient, region, team_size, fill).call
    end

    def initialize(recipient, region, team_size, fill)
      @recipient = recipient
      @region = region
      @team_size = team_size
      @fill = fill

      @lobby_url = ''
      @lobby_sent = false

      @keep_alive_counter = 0
    end

    def call
      EM.run do
        @ws = Faye::WebSocket::Client.new(WEB_SOCKET_URL)

        @ws.on :open do |_|
          process_open_event
        end

        @ws.on :message do |event|
          process_message_event(event)
        end

        @ws.on :close do |event|
          process_close_event(event)
          EM.stop
        end
      end
    end

    # :open event
    def process_open_event
      logger.info 'Opened connection. Creating lobby'
      @ws.send create_lobby_command
    end

    def create_lobby_command
      {
        type: 'create',
        data: {
          roomData: { region: @region, teamMode: @team_size, autoFill: @fill },
          playerData: { name: 'survioBot' }
        }
      }.to_json
    end

    # :message event
    def process_message_event(event)
      logger.info 'Recieved new message:'
      logger.info event.data

      @new_event_data = JSON.parse(event.data)

      if state_event?
        send_lobby unless lobby_sent?
        @ws.close if player_joined?
      elsif keep_alive_event?
        @keep_alive_counter += 1
        close_lobby if @keep_alive_counter >= KEEP_ALIVE_TIMEOUT
      end
    end

    def state_event?
      @new_event_data['type'] == 'state'
    end

    def lobby_sent?
      @lobby_sent
    end

    def send_lobby
      @lobby_url = @new_event_data['data']['room']['roomUrl']
      @recipient.send_message(BASE_URL + @lobby_url)
      @lobby_sent = true
    end

    def player_joined?
      @new_event_data['data']['players'].count > 1
    end

    def keep_alive_event?
      @new_event_data['type'] == 'keepAlive'
    end

    def close_lobby
      @recipient.send_message("Nobody joined the #{@lobby_url} lobby T-T")
      @ws.close
    end

    # :close event
    def process_close_event(event)
      logger.info 'Closing connection'
      logger.info [event.code, event.reason]
    end
  end
end
