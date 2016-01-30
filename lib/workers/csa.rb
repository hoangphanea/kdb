require "csv"

class Csa
  include Sidekiq::Worker

  def perform
    Song.where(song_id: %w(62100 66374 61188)).each do |id|
      Csaw.perform_async(id)
    end
  end

  def normalize(str)
    str.gsub(/[.,+\-*;!?:_]+/, '')
  end
end
