class Singer < ActiveRecord::Base
  has_many :records
  has_many :songs, through: :records
end
