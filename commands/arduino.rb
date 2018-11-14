require_relative 'lobby'

module Commands
  class Arduino
    def initialize(recipient)
      @recipient = recipient
    end
    attr_reader :recipient

    def call
      recipient.send_message('Pretend being an Arduino *click*')
      Lobby.new(recipient).call
    end
  end
end
