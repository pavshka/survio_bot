require_relative '../services/create_lobby'

module Commands
  class Squad
    def self.call(recipient)
      Services::CreateLobby.call(recipient: recipient)
    end
  end
end
