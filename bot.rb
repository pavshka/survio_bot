require 'telegram/bot'
require_relative 'worker'
require 'pry'

token = ENV['BOT_TOKEN']
puts 'Running capybara worker'
worker = Worker.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text == '/lobby'
      puts "\nCreating lobby"
      link = worker.create_lobby
      puts "Lobby: #{link}"
      bot.api.send_message(chat_id: message.chat.id, text: link)
      puts 'Waiting for other players'
      worker.wait_for_other_players ? puts('Player joined') : puts('Nobody joined the game')
      puts 'Leaving the lobby'
      worker.leave_lobby
    end
  end
end
