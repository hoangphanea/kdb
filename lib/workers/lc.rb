require 'open-uri'

class Lc
  include Sidekiq::Worker

  def perform(id)
    song = Song.find(id)
    # search = Nokogiri::HTML(open("http://lyric.tkaraoke.com/s.tim?q=#{URI.encode(song.short_lyric.mb_chars.downcase.to_s.gsub(/[\.\? !,-:]+/, ' ').strip)}&t=4"))
    # css = search.css('.div-result-item .h4-title-song a')
    # href = css[0].attributes['href'].value
    song_page = Nokogiri::HTML(open("http://www.masobaihatkaraoke.com/maso/#{song.song_id}"))
    ld = song_page.css('.SongLyric span')[0]
    lyric = ld.to_s.gsub(/[,\.]?(<br>|\n)+/, ' ').gsub(/(\n|\r)+/, ' ').gsub(/\t+/, ' ')
    song.update(lyric: Nokogiri.HTML(lyric).text.mb_chars.upcase.to_s.strip)
  rescue Exception => e
    p 'error'
    p e
  end
end
