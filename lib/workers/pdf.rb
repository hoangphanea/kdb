require "csv"

class Pdf
  include Sidekiq::Worker

  def perform
    csv = CSV.parse(open('eng.csv').read)
    songs = []
    csv.each do |row|
      tokens = []
      row.each do |token|
        tokens << token if token.present?
        if tokens.count == 3
          if tokens[0] != 'title'
            songs << Song.new(name: tokens[0], song_id: tokens[1], singer: tokens[2], stype: 'Arirang English')
          end
          break
        end
      end
    end
    Song.import(songs)
  rescue Exception => e
    p e
  end
end
