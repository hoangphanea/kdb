class ContinuousSlc
  include Sidekiq::Worker

  def perform
    while (Page.count < 497)
      (497.times.to_a - Page.pluck(:page_num)).each {|page| Slc.perform_async(page)}
      sleep 3
      Reauthorizer.perform_async
      sleep 4
    end
  end
end
