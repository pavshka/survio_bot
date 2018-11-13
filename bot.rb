require 'telegram/bot'
require_relative 'worker'

token = ENV['BOT_TOKEN']
puts 'Bot started listening'

def run_bot(bot)
  bot.listen do |message|
    begin
      command = message.text.split('@').first

      case command
      when '/lobby' then process_lobby_command(bot, message)
      when '/arduino' then process_arduino_command(bot, message)
      else
        puts "Received unsupportd #{message.text}"
      end
    rescue => e
      process_error(e)
      next
    end
  end
end

def create_lobby(bot, message)
  # TODO: Kill unused threads
  Thread.new { Worker.new(bot, message) }
end

def process_lobby_command(bot, message)
  puts 'Received /lobby message'
  create_lobby(bot, message)
end

def process_arduino_command(bot, message)
  puts 'Received /arduino message'
  bot.api.send_message(chat_id: message.chat.id, text: 'Pretending to be an Arduino *click*')
  create_lobby(bot, message)
end

def process_error(error)
  puts 'Error was raised:'
  puts error
  # TODO: Add error handling service
end

Telegram::Bot::Client.run(token) do |bot|
  begin
    retries ||= 0
    run_bot(bot)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    process_error(e)
    retry if (retries += 1) < 5
  end
end
