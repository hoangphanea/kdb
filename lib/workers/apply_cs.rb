require "csv"

class ApplyCs
  include Sidekiq::Worker

  def perform
    csv = CSV.read('similar.csv', headers: true)
    csv.each do |row|
      Song.where(stype: 'Music Core').where(song_id: row['id 1']).update_all(
        name: row['name 1'],
        lyric: row['lyric 1']
      )
    end
  end
end
