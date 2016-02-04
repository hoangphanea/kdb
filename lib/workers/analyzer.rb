require 'csv'

class Analyzer
  include Sidekiq::Worker

  THRESHOLD = 0.7

  def perform
    file_name = 'error.csv'
    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id score name short_lyric lyric)

      Song.where("#{regex_for('lyric')} not like \'%\' || #{regex_for('short_lyric')} || \'%\'").where(stype: 'Music Core').find_each do |song|
        s = song.short_lyric.gsub /[+\-\;"',.?! ]+/, ''
        l = song.lyric.gsub /[+\-\;"',.?! ]+/, ''
        matcher = Amatch::Levenshtein.new(s)
        csv << [song.id, matcher.search(l), song.name, song.short_lyric, song.lyric]
      end
    end
  rescue Exception => e
    p 'error'
    p e
  end

  def regex_for(field)
    "regexp_replace(#{field}, \'[\. ,\?!-]+\', \'\', \'g\')"
  end
end
