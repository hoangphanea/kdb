require "csv"

class DropboxUploader
  include Sidekiq::Worker
  ACCESS_TOKEN = DBENV['db_key']

  # def perform(vol)
  #   # DropboxLink.where(vol: vol).delete_all
  #   file_name = "vol_#{vol}.csv"

  #   CSV.open(file_name, 'wb') do |csv|
  #     csv << %w(id name author lyric utf)
  #     Song.where(vol: vol).find_each do |song|
  #       csv << [song.song_id, song.name, song.singer, song.lyric, song.utf8_lyric]
  #     end
  #   end
  #   $client.put_file("/#{file_name}", open(file_name))
  #   response = $session.do_get "/shares/auto/#{$client.format_path('/' + file_name)}", {"short_url"=>false}
  #   result = Dropbox::parse_response(response)
  #   DropboxLink.create(vol: vol, link: result['url'].gsub('?dl=0', '?dl=1'))
  # rescue Exception => e
  #   p e
  # end

  def perform
    file_name = 'links.csv'
    CSV.open('links.csv', 'wb') do |csv|
      csv << %w(vol link)
      DropboxLink.find_each do |dl|
        csv << [dl.vol, dl.link]
      end
    end
    $client.put_file("/#{file_name}", open(file_name))
  end
end
