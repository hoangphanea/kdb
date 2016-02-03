require 'open-uri'

class HcCrawler
  include Sidekiq::Worker

  def perform(id)
    record = Record.find(id)
    eid = record.link.split(/[\/.]/)[-2]
    hc = JSON[open("http://mp3.zing.vn/xhr/song/get-total-play?id=#{eid}&type=song").read]['total_play']
    record.update(hit_count: hc.to_i)
  rescue Exception => e
    p 'error'
    p e
  end
end
