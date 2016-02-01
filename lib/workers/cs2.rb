require "csv"

class Cs2
  include Sidekiq::Worker

  def perform
    CSV.open('similar.csv', 'wb') do |csv|
      csv << ['id 1', 'name 1', 'id 2', 'name 2', 'short_lyric 1', 'lyric 1','lyric 2']
      Song.where(stype: 'Music Core').where(vol: 6789, lyric: '').find_each do |song|
        ar = Song.where(stype: 'Arirang 5').fuzzy_search(short_lyric: song.short_lyric).first
        csv << [song.song_id, song.name, ar.try(:song_id), ar.try(:name), song.short_lyric, song.lyric, ar.try(:lyric)]
      end
    end
  end

  def normalize(str)
    str.gsub(/[.,+\-*;!?:_]+/, '')
  end
end
