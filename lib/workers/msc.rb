require "csv"

class Msc
  include Sidekiq::Worker

  def perform
    csv = CSV.parse(open('result.csv').read)
    song_ids = Song.where(stype: 'Music Core').pluck(:song_id)
    songs = []
    csv.each do |row|
      if song_ids.exclude? row[0]
        songs << Song.new(stype: 'Music Core', vol: 6789, name: row[1], song_id: row[0], singer: row[2], short_lyric: row[3])
      end
    end
    Song.import(songs)
  end
end
