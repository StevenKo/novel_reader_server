env :PATH, ENV['PATH']

every :day, :at => '11:50pm' do
  rake 'crawl:crawl_article_text',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end