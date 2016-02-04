require 'open-uri'

class NctSongChecker
  include Sidekiq::Worker

  def perform(id)
    record = Record.find(id)
    song = record.song
    s = song.short_lyric.gsub /[+\-\;"',.?! ]+/, ''
    matcher = Amatch::Levenshtein.new(s)

    song_page = Nokogiri::HTML(open(record.link))
    ld = song_page.css('#divLyric')[0]
    lyric = ld.to_s.gsub(/[,\.]?(<br>|\n)+/, '. ').gsub(/(\n|\r)+/, ' ').gsub(/\t+/, ' ')
    lyric = Nokogiri.HTML(lyric).text.mb_chars.upcase.to_s.strip
    l1 = lyric.gsub /[+\-\;"',.?! ]+/, ''
    score = matcher.search(l1)
    p lyric
    p song.short_lyric
    p score
    if score > 10
      p 'deleted'
      record.delete
    end
  rescue Exception => e
    p 'error'
    p e
  end
end
