require 'telegram/bot'
require_relative 'commands/lobby'
require_relative 'commands/arduino'

class SurviBot
  def initialize
    @token = ENV['BOT_TOKEN']
    @log = Logger.new(STDOUT)
  end
  attr_reader :token, :log, :bot

  def self.call
    new.call
  end

  def call
    log.info 'Starting bot'

    Telegram::Bot::Client.run(token) do |bot|
      @bot = bot

      begin
        retries ||= 0
        listen_to_commands
      rescue Telegram::Bot::Exceptions::ResponseError => e
        process_error(e)
        sleep(retries += 1)
        retry if retries < 5
      end
    end
  end

  def listen_to_commands
    bot.listen do |message|
      begin
        case extract_command(message)
        when '/lobby'
          Thread.new { Commands::Lobby.new(bot, message).call }
        when '/arduino'
          Thread.new { Commands::Arduino.new.call }
        else
          log.warn("Received unsupported message: #{message.text}")
        end
      rescue => e
        process_error(e)
        next
      end
    end
  end

  def extract_command(message)
    return unless message.text

    message.text.split('@').first
  end

  def process_error(error)
    log.error 'Error was raised:'
    log.error error
    # TODO: Add error handling service
  end
end
