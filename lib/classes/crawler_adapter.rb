# encoding: UTF-8

class CrawlerAdapter
  
  attr_accessor :adapter_map

  def self.adapter_map
    {
      '努努' => {'pattern'=>'/book.kanunu.org/si','name'=>'KanunuNovelCrawler','crawl_site_articles' => true,'recommend' => true},
      '精品文學' => {'pattern'=>'/www.bestory.com/si','name'=>'BestoryNovelCrawler','crawl_site_articles' => true,'recommend' => false}
    }
  end


  def self.get_instance url, option = {}

    @match = match_url(URI.encode(url))

    if @match.blank?
      @match = {'name' => 'NovelCrawler'}
    end

    @adapter = eval 'Crawler::'+@match['name'] + ".new"
  end

  private

    def self.match_url url
      match = nil
      CrawlerAdapter.adapter_map.each do |site, info|
        pattern = eval info['pattern']
        if pattern.match url
          puts "match pattern name:" + info['name']
          match = info
          break
        end
      end
      return match
    end
end