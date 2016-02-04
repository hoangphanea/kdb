require 'open-uri'

class SongsMatcher
  include Sidekiq::Worker

  def perform(singer_id)
    singer = Singer.find(singer_id)
    page = 0
    Record.where(singer: singer).delete_all
    records = []
    while true
      page += 1
      search = Nokogiri::HTML(open("#{singer.link}/bai-hat?&page=#{page}"))
      if (css = search.css('.list-item .fn-song .info-dp .txt-primary a')).present?
        css.each do |song_css|
          begin
            song_name = song_css.attributes['title'].to_s.split(/[\-\()]/).first.strip.mb_chars.upcase.to_s
            if song_name
              ["Arirang 5", "California", "Music Core", "Viet KTV"].each do |stype|
                songs = Song.where('UPPER(name) = ?', song_name).where(stype: stype)
                songs.each do |song|
                  records << Record.new(song: song, singer: singer, link: song_css.attributes['href'])
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
    Record.import(records)
  rescue Exception => e
    p 'error'
    p e
  end
end
