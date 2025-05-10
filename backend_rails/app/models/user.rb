class User < ApplicationRecord
  has_secure_password
  validates :username, uniqueness: true

  def to_s
    "#{id} -#{token} - #{username} - #{role} - #{created_at} - #{updated_at}"
  end
end
