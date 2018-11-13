require 'faye/websocket'
require 'eventmachine'
require 'json'

module Commands
  class Lobby
    def initialize(bot, message)
      # TODO: refactor command. Shouldn't know anything about bot and message
      @bot = bot
      @tlg_message = message
      @lobby_sent = false
    end

    def call
      puts 'Initializing worker'

      # TODO: figure out how event machine works
      EM.run do
        ws = Faye::WebSocket::Client.new('ws://surviv.io/team')

        ws.on :open do |_|
          puts 'Opened connection. Creating lobby...'
          ws.send create_lobby
        end

        ws.on :message do |event|
          puts 'Recieved new message:'
          puts event.data

          data = JSON.parse(event.data)
          unless keep_alive?(data)
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

    def keep_alive?(data)
      data['type'] == 'keepAlive'
    end

    def lobby_sent?
      @lobby_sent
    end

    def send_lobby
      room_url = @new_event_data['data']['room']['roomUrl']
      link = "http://surviv.io/#{room_url}"
      @bot.api.send_message(chat_id: @tlg_message.chat.id, text: link)
      @lobby_sent = true
    end

    def player_joined?
      @new_event_data['data']['players'].count > 1
    end
  end
end
