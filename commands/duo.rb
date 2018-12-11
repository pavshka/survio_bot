require_relative '../services/create_lobby'

module Commands
  class Duo
    def self.call(recipient)
      Services::CreateLobby.call(recipient: recipient, team_size: 2)
    end
  end
end
