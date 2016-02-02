class ContinuousMsk1
  include Sidekiq::Worker

  def perform
    while (ids = Song.where("#{regex_for('lyric')} not like \'%\' || #{regex_for('short_lyric')} || \'%\'").where(stype: 'Music Core', vol: 6789, check: false).pluck(:id)).present?
      ids.each do |id|
        Msk1.perform_async(id)
      end
      sleep 3
      Reauthorizer.perform_async
      sleep 4
    end
  end

  def regex_for(field)
    "regexp_replace(#{field}, \'[\. ,\?!-]+\', \'\', \'g\')"
  end
end
