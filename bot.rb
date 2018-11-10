require 'telegram/bot'
require_relative 'worker'

token = ENV['BOT_TOKEN']
puts 'Bot started listening'
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text == '/lobby'
      puts 'Received /lobby message'
      Worker.new(bot, message)
    elsif message.text == '/arduino'
      puts 'Received /arduino message'
      bot.api.send_message(chat_id: message.chat.id, text: 'Pretending to be an Arduino *click*')
      Worker.new(bot, message)
    else
      puts "Received unsupportd #{message.text}"
    end
  end
end
