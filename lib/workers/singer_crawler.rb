require 'open-uri'

class SingerCrawler
  include Sidekiq::Worker

  def perform(page)
    search = Nokogiri::HTML(open("http://mp3.zing.vn/the-loai-nghe-si/Viet-Nam/IWZ9Z08I.html?page=#{page}"))
    css = search.css('.pone-of-five')
    singers = []

    css.each do |artist|
      name = artist.attributes['data-name'].to_s
      link = artist.css('.item a.thumb')[0].attributes['href'].to_s
      singers << Singer.new(name: name, link: link)
    end
    Singer.import(singers)
  rescue Exception => e
    p 'error'
    p e
  end
end
