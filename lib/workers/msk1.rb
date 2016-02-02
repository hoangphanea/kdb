require 'open-uri'
require 'sidekiq/api'

class Msk1
  include Sidekiq::Worker

  def perform(id)
    db_song = Song.find(id)
    all = Nokogiri::HTML(open("http://www.masokaraoke.net/music-core/#{db_song.song_id}/"))
    if content = all.try(:css, '#resultSong').first
      db_song.update(name: content.css('.song .songName').first.text, singer: content.css('.song .author').first.text, short_lyric: content.css('.song .SongLyric').first.text, check: true)
    else
      Sidekiq::Queue.new('default').clear
      Sidekiq::RetrySet.new.clear
      Sidekiq::ScheduledSet.new.clear
    end
  rescue Exception => e
    p e
  end
end
