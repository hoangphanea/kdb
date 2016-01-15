require 'open-uri'
require 'sidekiq/api'

class Slc
  include Sidekiq::Worker

  def perform(page)
    return if Page.exists?(page_num: page)
    all = nil
    loop do
      break if all = Nokogiri::HTML(open("http://www.masokaraoke.net/list-karaoke//?page=#{page}"))
    end
    if content = all.try(:css, '#resultSong').try(:first)
      songs = []
      content.css('.song').each do |song|
        ids = song.css('.songID').text.split(' vol')
        if (id = ids[0]).present?
          if record = Song.find_by(song_id: id.strip)
            record.update(short_lyric: song.css('.SongLyric').text.gsub(/(\n|\r\n)/, '. '))
          else
            p id
          end
        end
      end
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
