require 'telegram/bot'
require_relative 'worker'
require 'pry'

token = ENV['BOT_TOKEN']
worker = Worker.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text == '/lobby'
      url = worker.create_lobby
      bot.api.send_message(chat_id: message.chat.id, text: url)
      worker.wait_for_other_players
    end
  end
end
