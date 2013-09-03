class CrawlerAdapter
  
  attr_accessor :adapter_map

  def self.adapter_map
    {
      'KanunuNovelCrawler' => {'pattern'=>'/book.kanunu.org/si','name'=>'KanunuNovelCrawler'},
      'BestoryNovelCrawler' => {'pattern'=>'/www.bestory.com/si','name'=>'BestoryNovelCrawler'}
    }
  end


  def self.get_instance url, option = {}

    @match = match_url(URI.encode(url))

    if @match.blank?
      @match = {'name' => 'NovelCrawler'}
    end

    @adapter = eval @match['name'] + ".new"
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