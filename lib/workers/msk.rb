require 'open-uri'

class Msk
  include Sidekiq::Worker

  def perform(page)
    return if Page.exists?(page_num: page)
    all = nil
    loop do
      break if all = Nokogiri::HTML(open("http://www.masokaraoke.net/list-karaoke//?page=#{page}"))
    end
    return unless content = all.try(:css, '#resultSong').try(:first)
    songs = []
    song_ids = Song.pluck(:song_id)
    content.css('.song').each do |song|
      ids = song.css('.songID').text.split(' vol')
      if (id = ids[0]).present? && song_ids.exclude?(id)
        vol = ids[1].to_i
        name = song.css('.songName').text
        singer = song.css('.author').text
        songs << Song.new(vol: vol, song_id: id, name: name, singer: singer, stype: 'Arirang 5')
      end
    end
    Song.import(songs)
    Page.create(page_num: page)
  end
end
