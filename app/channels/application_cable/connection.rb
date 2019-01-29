module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :uuid

    def connect
      self.uuid = SecureRandom.urlsafe_base64
      if env['warden'].user
        self.current_user = find_verified_user
      end
    end

    protected

    def find_verified_user
      return User.find_by(id: cookies.signed['user.id'])
    end
  end
end
