require "csv"

class Checker
  include Sidekiq::Worker

  def perform
    file_name = 'error.csv'
    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id song_id name author short_lyric lyric)
      # Song.where(check: true).find_each do |song|
      Song.where("#{regex_for('lyric')} like \'%\' || #{regex_for('short_lyric')} || \'%\'").where(stype: 'Music Core', vol: 6789, check: true).find_each do |song|
        csv << [song.id, song.song_id, song.name, song.singer, song.short_lyric, song.lyric]
      end
    end
    # Song.where("#{regex_for('lyric')} not like CONCAT(#{regex_for('short_lyric')} ,\'%\')").find_each {|song| Lc.perform_async(song.id) }
  end

  def regex_for(field)
    "regexp_replace(#{field}, \'[\. ,\?!-]+\', \'\', \'g\')"
  end
end
