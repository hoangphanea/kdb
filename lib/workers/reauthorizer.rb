class Reauthorizer
  include Sidekiq::Worker

  def perform
    MyCapybara::Crawler.new.crawl
  rescue
    p 'Nothing to do'
  end
end

module MyCapybara
  class Crawler
    include Capybara::DSL
    def crawl
      visit("/")
      click_on('target') if find('#target')
    end
  end
end
