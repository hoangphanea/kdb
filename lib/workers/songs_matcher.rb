require 'open-uri'

class SongsMatcher
  include Sidekiq::Worker

  def perform(singer, link)
    page = 0
    while true
      page += 1
      search = Nokogiri::HTML(open("#{link}/bai-hat?&page=#{page}"))
      if (css = search.css('.list-item .fn-song .info-dp .txt-primary a')).present?
        css.each do |song_css|
          begin
            song_name = song_css.attributes['title'].to_s.split(/[\-\()]/).first.strip.mb_chars.upcase.to_s
            if song_name
              ["Arirang 5", "California", "Music Core", "Viet KTV"].each do |stype|
                songs = Song.where('UPPER(name) = ?', song_name).where(stype: stype)
                if songs.count == 1
                  song = songs.first
                  singers = Set.new(song.singer.split(' ; '))
                  singers << singer
                  song.update(singer: singers.to_a.join(' ; '))
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
  rescue Exception => e
    p 'error'
    p e
  end
end
