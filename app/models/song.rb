class Song < ActiveRecord::Base
  has_many :records
  has_many :singers, through: :records
end
