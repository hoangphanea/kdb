require "csv"

class DropboxUploader
  include Sidekiq::Worker
  ACCESS_TOKEN = DBENV['db_key']

  def perform(vol, type)
    file_name = "vol_#{vol}_#{type.parameterize.underscore}.csv"
    zip_file = "#{file_name}.zip"

    CSV.open(file_name, 'wb') do |csv|
      csv << %w(id name author singer lyric)

      id_hc_sql = Record.joins(:song).group(:song_id).select('MAX(hit_count)', :song_id).to_sql

      Record.joins(:song).joins(:singer).where('songs.stype = ?', type).where('songs.vol = ?', vol).where("(records.hit_count, records.song_id) IN (#{id_hc_sql})").group('1,2,3,5').pluck('songs.song_id', 'songs.name', 'songs.author', 'array_agg(singers.name)', 'songs.lyric').each do |row|
        csv << [row[0], row[1], row[2], row[3].join(', '), row[4]]
      end

      Song.includes(:records).where(vol: vol, stype: type).where(records: { id: nil }).find_each do |song|
        csv << [song.song_id, song.name, song.author, '', song.lyric]
      end
    end

    if (rows = CSV.read(file_name).count - 1) != (songs_count = Song.where(stype: type, vol: vol).count)
      p "Song number check failed in vol #{vol} #{type}, #{rows} rows compared to #{songs_count} songs"
      return
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
