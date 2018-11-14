require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative '../lib/logging'

module Commands
  class Lobby
    BASE_URL = 'http://surviv.io/'.freeze
    WEB_SOCKET_URL = 'ws://surviv.io/team'.freeze
    include Logging

    def initialize(recipient)
      @recipient = recipient
      @lobby_sent = false
    end
    attr_reader :recipient, :lobby_sent

    def call
      logger.info 'Executing /lobby command'

      # TODO: figure out how event machine works
      EM.run do
        ws = Faye::WebSocket::Client.new(WEB_SOCKET_URL)

        ws.on :open do |_|
          logger.info 'Opened connection. Creating lobby...'
          ws.send create_lobby
        end

        ws.on :message do |event|
          logger.info 'Recieved new message:'
          logger.info event.data

          data = JSON.parse(event.data)
          if state_event?(data)
            @new_event_data = data

            send_lobby unless lobby_sent?
            ws.close if player_joined?
          end
        end

        ws.on :close do |event|
          puts 'Closing connection'
          puts [event.code, event.reason]
          EM.stop
        end
      end
    rescue StandardError => e
      logger.error e
    end

    def create_lobby(region = 'eu', team = 4, fill = false)
      {
        type: 'create',
        data: {
          roomData: { region: region, teamMode: team, autoFill: fill },
          playerData: { name: 'survioBot' }
        }
      }.to_json
    end

    def state_event?(data)
      data['type'] == 'state'
    end

    def lobby_sent?
      @lobby_sent
    end

    def send_lobby
      room_url = @new_event_data['data']['room']['roomUrl']
      url = BASE_URL + room_url
      recipient.send_message(url)
      @lobby_sent = true
    end

    def player_joined?
      @new_event_data['data']['players'].count > 1
    end
  end
end
