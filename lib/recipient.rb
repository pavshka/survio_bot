class Recipient
  def initialize(bot, chat)
    @bot = bot
    @chat = chat
  end
  attr_reader :bot, :chat

  def send_message(message)
    bot.api.send_message(chat_id: chat.id, text: message)
  end
end
