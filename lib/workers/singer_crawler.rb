require 'open-uri'

class SingerCrawler
  include Sidekiq::Worker

  def perform
    (101..169).each do |page|
      search = Nokogiri::HTML(open("http://mp3.zing.vn/the-loai-nghe-si/Viet-Nam/IWZ9Z08I.html?page=#{page}"))
      
      css = search.css('.pone-of-five')

      css.each do |artist|
        name = artist.attributes['data-name'].to_s
        link = artist.css('.item a.thumb')[0].attributes['href'].to_s
        SongsMatcher.perform_async(name, link)
      end
    end
  rescue Exception => e
    p 'error'
    p e
  end
end
