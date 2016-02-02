require 'open-uri'

class Lc
  include Sidekiq::Worker

  def perform(id)
    song = Song.find(id)
    search = Nokogiri::HTML(open("http://nhac.vui.vn/tim-nhac/#{URI.encode(song.name.gsub('(remix)', '').strip)}"))
    # search = Nokogiri::HTML(open("http://mp3.zing.vn/tim-kiem/bai-hat.html?q=#{URI.encode(song.name.gsub('(remix)', '').strip)}"))
    # css = search.css('.page-search .item-song .title-song a')
    css = search.css('#div_ket_qua_tim_kiem .centerBoxPad .listNhac-title')

    chosen = song.lyric

    s = song.short_lyric.gsub /[+\-\;"',.?! ]+/, ''
    l = song.lyric.gsub /[+\-\;"',.?! ]+/, ''
    matcher = Amatch::Levenshtein.new(s)

    high_score = matcher.search(l)

    4.times do |n|
      begin
        href = css[n].attributes['href'].value
        song_page = Nokogiri::HTML(open('http://nhac.vui.vn' + href))
        ld = song_page.css('.nghenhac-loibaihat-cnt')[1]
        ld.search('.//div').remove
        # ld = song_page.css('.fn-lyrics p.fn-content')[2]
        lyric = ld.to_s.gsub(/[,\.]?(<br>|\n)+/, '. ').gsub(/(\n|\r)+/, ' ').gsub(/\t+/, ' ')
        lyric = Nokogiri.HTML(lyric).text.mb_chars.upcase.to_s.strip
        l1 = lyric.gsub /[+\-\;"',.?! ]+/, ''
        score = matcher.search(l1)
        if score < high_score
          p "Score change from #{high_score} to #{score}"
          high_score = score
          chosen = lyric
          break if score == 0
        end
      rescue Exception => e
        p 'error'
        p e
      end
    end
    song.update(lyric: chosen)
  rescue Exception => e
    p 'error'
    p e
  end
end
