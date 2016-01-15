require "csv"
require "open-uri"

class Updater
  include Sidekiq::Worker

  def perform(link_id)
    dropbox_link = DropboxLink.find(link_id)
    csv = CSV.parse(open(dropbox_link.link).read, headers: true)
    songs = []
    csv.each do |row|
      songs << Song.new(name: row['name'], lyric: row['lyric'], song_id: row['id'], singer: row['author'], vol: dropbox_link.vol)
    end
    Song.import songs
  rescue Exception => e
    p '======= Error ========'
    p e
  end
end
