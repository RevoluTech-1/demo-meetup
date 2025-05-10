
class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :role, :created_at, :updated_at
end
