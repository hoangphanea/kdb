require "csv"

class Csa
  include Sidekiq::Worker

  def perform
    Song.where(stype: 'Music Core').where(vol: 6789, lyric: '', check: false).pluck(:id).each do |id|
      Csaw.perform_async(id)
    end
  end

  def normalize(str)
    str.gsub(/[.,+\-*;!?:_]+/, '')
  end
end
