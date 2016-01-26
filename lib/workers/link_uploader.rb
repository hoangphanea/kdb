require "csv"

class LinkUploader
  include Sidekiq::Worker
  ACCESS_TOKEN = DBENV['db_key']

  def perform
    file_name = 'links.csv'
    zip_file = 'links.zip'
    CSV.open('links.csv', 'wb') do |csv|
      csv << %w(vol type link)
      DropboxLink.find_each do |dl|
        csv << [dl.vol, dl.stype, dl.link]
      end
    end

    data = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(DBENV['link_password'])) do |out|
      out.put_next_entry(file_name)
      out.write File.read(file_name)
    end

    File.open(zip_file, 'w') do |f|
      f.write data.string
    end

    $client.put_file("/#{zip_file}", open(zip_file))
  end
end
