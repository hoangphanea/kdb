require 'open-uri'

class NctSongsMatcher
  include Sidekiq::Worker
  include Capybara::DSL

  def perform
    singer = Singer.find_by('name ilike ?', 'Minh Quân')
    page = 0
    records = []
    while true
      page += 1
      visit "http://www.nhaccuatui.com/nghe-si-minh-quan.bai-hat.#{page}.html"
      if (css = all('ul.list_item_music > li')).present?
        css.each do |song_css|
          begin
            link_css = song_css.first('a.name_song')
            song_name = link_css.text.to_s.split(/\(/).first.strip.mb_chars.upcase.to_s
            if song_name
              ["Arirang 5", "California", "Music Core", "Viet KTV"].each do |stype|
                songs = Song.where('UPPER(name) = ?', song_name).where(stype: stype)
                songs.each do |song|
                  hc = song_css.first('span.icon_listen').text.gsub('.', '').strip.to_i
                  p hc
                  records << Record.new(song: song, singer: singer, link: link_css['href'], hit_count: hc)
                end
              end
            end
          rescue Exception => e
            p 'error'
            p e
          end
        end
      else
        break
      end
    end
    records.each { |r| p "#{r.link} - #{r.hit_count}" }
    Record.import(records)
  rescue Exception => e
    p 'error'
    p e
  end
end
