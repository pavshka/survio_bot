require 'telegram/bot'
require_relative 'commands/lobby'
require_relative 'commands/arduino'
require_relative 'lib/logging'
require_relative 'lib/recipient'

class SurviBot
  MAX_RETIRES = 5
  include Logging

  def initialize
    logger.info 'Starting bot'
    @token = ENV['BOT_TOKEN']
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen { |message| process_message(message, bot) }
    end
  rescue StandardError => e
    retry if handle_error(e)
  end

  def process_message(message, bot)
    recipient = Recipient.new(bot, message.chat)

    case extract_command(message)
    when '/lobby'
      Thread.new { Commands::Lobby.new(recipient).call }
    when '/arduino'
      Thread.new { Commands::Arduino.new(recipient).call }
    else
      logger.warn("Received unsupported message: #{message.text}")
    end
  end

  def extract_command(message)
    return unless message.text

    message.text.split('@').first
  end

  def handle_error(error)
    logger.error 'Error was raised:'
    logger.error error

    @retries ||= 0
    sleep(@retries += 1)
    # TODO: Add error handling service

    @retries < MAX_RETIRES
  end
end
