require 'open-uri'

class Lc
  include Sidekiq::Worker

  def perform(id)
    song = Song.find(id)
    search = Nokogiri::HTML(open("http://mp3.zing.vn/tim-kiem/bai-hat.html?q=#{URI.encode(song.name.gsub('(remix)', '').strip)}"))
    css = search.css('.page-search .item-song .title-song a')
    href = css[0].attributes['href'].value
    song_page = Nokogiri::HTML(open(href))
    ld = song_page.css('.fn-lyrics p.fn-content')[2]
    lyric = ld.to_s.gsub(/[,\.]?(<br>|\n)+/, '. ').gsub(/(\n|\r)+/, ' ').gsub(/\t+/, ' ')
    song.update(lyric: Nokogiri.HTML(lyric).text.mb_chars.upcase.to_s.strip)
  rescue Exception => e
    p 'error'
    p e
  end
end
