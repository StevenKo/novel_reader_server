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

    if url.index('shushu5')||url.index('kushuku')||url.index('feiku.com')|| url.index('daomubiji') || url.index('luoqiu.com') || url.index('kxwxw')
      @page_html = Nokogiri::HTML(body)
    elsif url.index('xybook.net') || url.index('uuxs.com')
      html = open(url).read
      # charset = Nokogiri::HTML(html).meta_encoding
      html.force_encoding("gbk")
      html.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
      @page_html = Nokogiri::HTML.parse html
    elsif (url.index('shanwen')|| url.index('shushu')|| url.index('sj131') || url.index('59to.com') || url.index('quanben') || url.index('xianjie') || url.index('u8xs') || url.index('dawenxue') || url.index('shu88') || url.index('77wx') || url.index('xuanhutang') || url.index('5ccc.net') || url.index('520xs') || url.index('92txt.net') || url.index('ranwenxiaoshuo') || url.index('qbxiaoshuo') || url.index('xhxsw')|| url.index('lwxs') || url.index('5200xs') || url.index('hfxs') || url.index('5800.cc') || url.index('bjxiaoshuo') || url.index('d586.com') || url.index('bookzx.net') || url.index('qizi.cc') || url.index('ttshuo') || url.index('wenku8.cn') || url.index('wsxs.net') || url.index('yawen8') || url.index('fftxt.net')  || url.index('qbxs8') || url.index('xiaoshuozhe'))
      @page_html = Nokogiri::HTML(body,nil,"GB18030")
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
    elsif (url.index('ww.qtxny.com'))
      /ww.qtxny.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.qtxny.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ww.duyidu.com'))
      /ww.duyidu.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.duyidu.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ww.23hh.com'))
      /ww.23hh.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.23hh.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('59to.org'))
      /tw.59to.org(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('tw.59to.org', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"big5")  
    elsif (url.index('book.kanunu.org'))
      /book.kanunu.org(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('book.kanunu.org', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('d5wx.com'))
      /ww.d5wx.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.d5wx.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('zwxiaoshuo.com'))
      /ww.zwxiaoshuo.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.zwxiaoshuo.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"big5")     
    elsif (url.index('qiuwu'))
      /ww.qiuwu.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.qiuwu.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('6yzw.com'))
      /ww.6yzw.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.6yzw.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030") 
    elsif (url.index('ww.yjwxw.com'))
      /ww.yjwxw.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.yjwxw.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030") 
    elsif (url.index('ww.shunong.com'))
      /ww.shunong.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.shunong.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")  
    elsif (url.index('ww.gosky.net'))
      /ww.gosky.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.gosky.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ww.quanshu.net'))
      /ww.quanshu.net(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.quanshu.net', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")  
    elsif (url.index('ww.qizi.cc'))
      /ww.qizi.cc(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.qizi.cc', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ww.yqwxc.com'))
      /ww.yqwxc.com(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.yqwxc.com', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")
    elsif (url.index('ww.yqhhy.cc'))
      /ww.yqhhy.cc(.*)/ =~ url
      url = $1
      http = Net::HTTP.new('www.yqhhy.cc', 80)
      res = http.get url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19', 'Cookie' => '_ts_id=360435043104370F39'
      content = res.body
      @page_html = Nokogiri::HTML(content,nil,"GB18030")                         
    elsif (url.index('zizaidu'))
      ic = Iconv.new("utf-8//translit//IGNORE","big5")
      body = ''

      begin
        open(url){ |io|
            body = ic.iconv(io.read)
        }
      rescue
      end
      @page_html = Nokogiri::HTML(body)             
    else
      if (body.index("charset=gbk"))
        body.force_encoding("gbk")
        body.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
        @page_html = Nokogiri::HTML.parse body
      else
        @page_html = Nokogiri::HTML(body)
      end
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