require "csv"

class Pdf
  include Sidekiq::Worker

  def perform
    col1 = ''
    col2 = ''
    col3 = ''
    buffer = []

    CSV.open('result.csv', 'wb') do |res|
      res << %w(id name author short_lyric)
      csv = CSV.parse(open('eng.csv').read)
      songs = []
      csv.each do |row|
        next if row[0].length < 2

        if row[0] == 'MÃ SỐ' || row[0] == 'TÊN BÀI HÁT'
          col1, col2, col3 = row
          next
        end

        if col3.blank?
          if col1 == 'MÃ SỐ'
            buffer << [row[0], row[1]]
          else
            values = buffer.shift + [row[1]]
            if matches = /((?:[[:upper:]]|[ ,.!?\r\n\d])+)([[:upper:]][[:lower:]].*)/.match(values[1])
              res << [values[0], matches[1], values[2], matches[2]]
            end
          end
        else
          if matches = /((?:[[:upper:]]|[ ,.!?\r\n\d])+)([[:upper:]][[:lower:]].*)/.match(row[1])
            res << [row[0], matches[1], row[2], matches[2]]
          end
        end
      end
    end
  end
end
