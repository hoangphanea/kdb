require "csv"

class SingerChecker
  include Sidekiq::Worker

  def perform
    file_name = 'error.csv'
    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id song_id name singer short_lyric lyric)

      id_hc_sql = Record.joins(:song).group(:song_id).select('MAX(hit_count)', :song_id).to_sql

      Record.includes(:song, :singer).where("(hit_count, song_id) IN (#{id_hc_sql})").each do |record|
        csv << [record.song_id, record.song.song_id, record.song.name, record.singer.name, record.song.short_lyric, record.song.lyric]
      end
    end
  end
end
