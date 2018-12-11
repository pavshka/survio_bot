class Recipient
  def initialize(bot, chat)
    @bot = bot
    @chat = chat
  end
  attr_reader :bot, :chat

  def send_message(message)
    bot.api.send_message(chat_id: chat.id, text: message)
  end

  def send_gif(path)
    bot.api.send_document(chat_id: chat.id, document: Faraday::UploadIO.new(path, 'image/gif'))
  end
end
