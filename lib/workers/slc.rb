require 'open-uri'
require 'sidekiq/api'

class Slc
  include Sidekiq::Worker

  def perform(page)
    return if Page.exists?(page_num: page)
    all = nil
    loop do
      break if all = Nokogiri::HTML(open("http://www.masokaraoke.net/music-core//?page=#{page}"))
    end
    if content = all.try(:css, '#resultSong').try(:first)
      songs = []
      song_ids = Song.pluck(:song_id)
      content.css('.song').each do |song|
        ids = song.css('.songID').text.split(' vol')
        if (id = ids[0]).present?
          ids = song.css('.songID').text.split(' vol')
          if (id = ids[0]).present? && song_ids.exclude?(id)
            vol = ids[1].to_i
            name = song.css('.songName').text
            singer = song.css('.author').text
            short_lyric = song.css('.SongLyric').text.gsub(/[,\.]?(<br>|\n)+/, ' ').gsub(/(\n|\r)+/, ' ').gsub(/\t+/, ' ').mb_chars.upcase.to_s.strip
            songs << Song.new(vol: vol, song_id: id, name: name, singer: singer, short_lyric: short_lyric, stype: 'Music Core')
          end
        end
      end
      Song.import(songs)
      Page.create(page_num: page)
    else
      Sidekiq::Queue.new('default').clear
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
    end
  rescue => e
    p e
    p 'error'
  end
end
