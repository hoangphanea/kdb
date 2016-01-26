require "csv"

class DropboxUploader
  include Sidekiq::Worker
  ACCESS_TOKEN = DBENV['db_key']

  def perform(vol, type)
    # DropboxLink.where(vol: vol).delete_all
    file_name = "vol_#{vol}_#{type.parameterize.underscore}.csv"
    zip_file = "#{file_name}.zip"

    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id name author lyric)
      Song.where(vol: vol, stype: type).find_each do |song|
        csv << [song.song_id, song.name, song.singer, song.lyric]
      end
    end

    password = SecureRandom.hex

    data = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(password)) do |out|
      out.put_next_entry(file_name)
      out.write File.read(file_name)
    end

    File.open(zip_file, 'w') do |f|
      f.write data.string
    end
    $client.put_file("/#{zip_file}", open(zip_file))
    response = $session.do_get "/shares/auto/#{$client.format_path('/' + zip_file)}", {"short_url"=>false}
    result = Dropbox::parse_response(response)
    DropboxLink.create(vol: vol, stype: type, password: encrypt(password), link: result['url'].gsub('?dl=0', '?dl=1'))
  rescue Exception => e
    p e
  end

  def encrypt(password)
    password.split('').map do |chr|
      if chr >= '0' && chr <= '9'
        ((chr.to_i + DBENV['encrypt_key'].to_i) % 10).to_s
      else
        chr
      end
    end.join('')
  end
end
