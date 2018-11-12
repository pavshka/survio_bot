require 'telegram/bot'
require_relative 'worker'

token = ENV['BOT_TOKEN']
puts 'Bot started listening'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    begin
      command = message.text.split('@').first

      if command == '/lobby'
        puts 'Received /lobby message'
        Thread.new { Worker.new(bot, message) }
      elsif command == '/arduino'
        puts 'Received /arduino message'
        bot.api.send_message(chat_id: message.chat.id, text: 'Pretending to be an Arduino *click*')
        Thread.new { Worker.new(bot, message) }
      else
        puts "Received unsupportd #{message.text}"
      end

    rescue => e
      puts 'Error was raised:'
      puts e
      next
    end
  end
end
