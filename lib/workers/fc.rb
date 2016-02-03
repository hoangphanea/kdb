require "csv"

class Fc
  include Sidekiq::Worker

  def perform
    csv = CSV.parse(open('error.csv').read, headers: true)
    csv.each do |row|
      Song.find_by(id: row['id']).update(name: row['name'], lyric: row['lyric'], short_lyric: row['short_lyric'], check: true)
    end
  end
end
