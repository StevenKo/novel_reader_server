env :PATH, ENV['PATH']

every :day, :at => '01:50pm' do
  rake 'crawl:crawl_novel_detail_and_articles',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end