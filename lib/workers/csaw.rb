require "csv"

class Csaw
  include Sidekiq::Worker

  def perform(id)
    if song = Song.find_by_id(id)
      Song.where(stype: 'Arirang 5').fuzzy_search(name: song.name).each do |ar|
        if ar.try(:lyric)
          if normalize(ar.lyric.mb_chars.upcase.to_s).include?(normalize(song.short_lyric).mb_chars.upcase.to_s)
            song.update(lyric: ar.lyric, name: ar.name)
            p 'success'
            break
          else 
            p 'not match'
          end
        else
          p 'not found'
        end
      end
      song.update(check: true)
    end
  end

  def normalize(str)
    str.gsub(/[.,+\-*;!?:_ ]+/, '')
  end
end
