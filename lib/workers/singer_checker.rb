require "csv"

class SingerChecker
  include Sidekiq::Worker

  def perform
    file_name = 'error.csv'
    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id song_id name singer short_lyric)

      id_hc_sql = Record.joins(:song).group(:song_id).select('MAX(hit_count)', :song_id).to_sql

      Record.joins(:song).joins(:singer).where('songs.stype = ?', 'Arirang 5').where("(records.hit_count, records.song_id) IN (#{id_hc_sql})").group('1,2,3,5').pluck(:song_id, 'songs.song_id', 'songs.name', 'array_agg(singers.name)', 'songs.short_lyric').each do |row|
        csv << [row[0], row[1], row[2], row[3].join(', '), row[4]]
      end
      Song.includes(:records).where(records: {id: nil}).where(stype: 'Arirang 5').find_each do |song|
        csv << [song.id, song.song_id, song.name, '', song.short_lyric]
      end
    end
  end
end
