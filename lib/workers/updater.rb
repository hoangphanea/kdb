require "csv"

class Updater
  include Sidekiq::Worker

  def perform
    csv = CSV.parse(open('restore.csv').read, headers: true)
    csv.each do |row|
      Song.find_by(id: row['id']).update(lyric: row['lyric'], short_lyric: row['short_lyric'])
    end
  rescue Exception => e
    p '======= Error ========'
    p e
  end
end
