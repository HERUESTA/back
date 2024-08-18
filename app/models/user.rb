class User < ApplicationRecord
  validates :uid, presence: true, uniqueness: true
  validates :name, presence: true
end