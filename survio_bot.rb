require 'telegram/bot'
require 'sentry-raven'
require 'dotenv'
Dotenv.load

require_relative 'lib/logging'
require_relative 'lib/recipient'

require_relative 'commands/arduino'
require_relative 'commands/duo'
require_relative 'commands/squad'

class SurvioBot
  include Logging

  def initialize
    logger.info 'Starting bot'
    @token = ENV['BOT_TOKEN']
    Raven.configure { |config| config.dsn = ENV['SENTRY_DSN'] }
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen { |message| process_message(bot, message) }
    end
  rescue StandardError => e
    handle_error(e)
    sleep 5 # Wait before retry(for connection issues)
    retry
  end

  def process_message(bot, message)
    recipient = Recipient.new(bot, message.chat)
    command = extract_command(message)
    processor = {
      '/arduino'    => -> { threaded { Commands::Arduino.call(recipient) } },
      '/squad'      => -> { threaded { Commands::Squad.call(recipient) } },
      '/duo'        => -> { threaded { Commands::Duo.call(recipient) } }
    }.fetch(command) { -> { logger.warn("Received unsupported message: #{message.text}") } }

    processor.call
  end

  def extract_command(message)
    return unless message.text

    message.text.split('@').first
  end

  def threaded
    Thread.new do
      begin
        yield
      rescue StandardError => e
        handle_error(e)
      end
    end
  end

  def handle_error(error)
    Raven.capture_exception(error)
    logger.error "Error was raised: #{error.message}"
  end
end
