module Crawler
  
  require 'nokogiri'
  require 'open-uri'
  require 'iconv'
  require 'net/http'
  
  attr_accessor :page_url, :page_html
  
  def fetch url
    @page_url = url
    @page_html = get_page(@page_url)   
  end

  def fetch_other_site url
    @page_url = url
    body = ''
    begin
      open(url){ |io|
          body = io.read
      }
    rescue
    end
    
    if (url.index('shanwen')|| url.index('shushu')|| url.index('sj131') || url.index('59to') || url.index('quanben') || url.index('xianjie') || url.index('u8xs') || url.index('dawenxue'))
      @page_html = Nokogiri::HTML(body,nil,"GB18030")

    elsif (url.index('yawen8'))
      /ww.yawen8.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.yawen8.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('www.8535.org'))
      /www.8535.org(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.8535.org', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('book.qq'))
      /book.qq.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('book.qq.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('www.k6uk.com'))
      /www.k6uk.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.k6uk.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('jjwxc'))
      /ww.jjwxc.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.jjwxc.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ranhen'))
      /ww.ranhen.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.ranhen.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('6ycn'))
      /ww.6ycn.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.6ycn.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('book108'))
      /ww.book108.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.book108.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    else
      @page_html = Nokogiri::HTML(body)
    end
  end

  def fetch_db_json url
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
    
    if(url.index('book.qq'))
      /bookapp.book.qq.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('bookapp.book.qq.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      doc = Nokogiri::HTML(content,nil,"GB18030")
    else
      ic = Iconv.new("utf-8//translit//IGNORE","big5")
      body = ''

      begin
        open(url){ |io|
            body = ic.iconv(io.read)
        }
      rescue
      end
      doc = Nokogiri::HTML(body)
    end
    doc
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

  
end