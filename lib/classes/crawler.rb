module Crawler
  
  require 'nokogiri'
  require 'open-uri'
  require 'iconv'
  require 'net/http'
  
  attr_accessor :page_url, :page_html, :fake_browser_urls, :do_not_encode_urls, :match_url_pattern
  
  def fetch url
    @fake_browser_urls = ["www.8535.org","6ycn.net","www.readnovel.com","www.d586.com","www.fftxt.com"]
    @do_not_encode_urls = ['ranwenba','shushu5','kushuku','feiku.com','daomubiji','luoqiu.com','kxwxw','txtbbs.com','lightnovel.cn','tw.xiaoshuokan','tw.57book','b.faloo.com/p/','9pwx.com','wcxiaoshuo']
    @page_url = url
    get_page(@page_url)   
  end

  def fetch_without_nokogiri url
    @page_url = url
    body = ''
    begin
      open(url){ |io|
          body = io.read
      }
    rescue
    end
    @page_html = body
  end

  def post_fetch url, option
    @page_url = url
    url = URI.parse(url)
    resp, data = Net::HTTP.post_form(url, option)
    @page_html = Nokogiri::HTML(resp.body)
  end
  
  def get_page url
    
    @page_url = url
    body = ''
    begin
      open(url){ |io|
          body = io.read
      }
    rescue
    end

    if isDoNotNeedReEncodeUrl(url)
      @page_html = Nokogiri::HTML(body)
    elsif isNeedFakeBrowserUrl(url)
      /#{@match_url_pattern}(.*)/ =~ url
      url = $1
      http = Net::HTTP.new(@match_url_pattern, 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    else
      tmp = body.encode("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
      @page_html = Nokogiri::HTML(tmp)
      encoding = @page_html.meta_encoding

      if (encoding == "gbk" || encoding == "gb2312")
        body.force_encoding("gbk")
        body.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
        @page_html = Nokogiri::HTML.parse body
      elsif(encoding == "big5")
        body.force_encoding("big5")
        body.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
        @page_html = Nokogiri::HTML(body,nil)
      else
        @page_html = Nokogiri::HTML(body)
      end
    end
  end

  def isDoNotNeedReEncodeUrl(url)
    @do_not_encode_urls.each do |check_pattern|
      return true if url.index(check_pattern)
    end
    return false
  end

  def isNeedFakeBrowserUrl(url)
    @fake_browser_urls.each do |check_pattern|
      if url.index(check_pattern)
        @match_url_pattern = check_pattern
        return true
      end
    end
    return false
  end

  def get_item_href dns, src
    if (/^\/\// =~ src)
      src = "http:" + src
    elsif (/^\// =~ src)
      src = dns + src
    elsif (/\.\./ =~ src)
      src = dns + src[2..src.length]
    else
      src 
    end
  end
  
  def parse_dns
    url_scan = @page_url.scan(/.*?\//)
    dns = url_scan[0] + url_scan[1] + url_scan[2]
  end

  def change_node_br_to_newline node
    content = node.to_html
    content = content.gsub("<br>","\n")
    n = Nokogiri::HTML(content)
    n.text
  end

  
end