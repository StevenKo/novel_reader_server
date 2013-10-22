# encoding: UTF-8

class CrawlerAdapter
  
  attr_accessor :adapter_map

  def self.adapter_map
    {
      '燃文小说网net' => {'pattern'=>'/ranwen.net/si','name'=>'Ranwen','crawl_site_articles' => true,'recommend' => true},
      '穿越小说吧131' => {'pattern'=>'/sj131.com/si','name'=>'Sj131','crawl_site_articles' => true,'recommend' => true},
      '我看书斋' => {'pattern'=>'/5ccc.net/si','name'=>'Ccc5','crawl_site_articles' => true,'recommend' => true},
      '落秋中文' => {'pattern'=>'/luoqiu.com/si','name'=>'Luoqiu','crawl_site_articles' => true,'recommend' => true},
      '飞卢小说网' => {'pattern'=>'/b.faloo.com/si','name'=>'Faloo','crawl_site_articles' => true,'recommend' => true},
      '伍九文学' => {'pattern'=>'/59to.com/si','name'=>'To59','crawl_site_articles' => true,'recommend' => true},
      '59文学' => {'pattern'=>'/59to.org/si','name'=>'To59Org','crawl_site_articles' => true,'recommend' => true},
      'SF轻小说' => {'pattern'=>'/book.sfacg.com/si','name'=>'Sfacg','crawl_site_articles' => true,'recommend' => true},
      '《小说阅读网》' => {'pattern'=>'/readnovel.com/si','name'=>'Readnovel','crawl_site_articles' => true,'recommend' => true},
      '轻小说文库' => {'pattern'=>'/wenku8.cn/si','name'=>'Wenku8','crawl_site_articles' => true,'recommend' => true},
      '努努' => {'pattern'=>'/book.kanunu.org/si','name'=>'Kanunu','crawl_site_articles' => true,'recommend' => true},

      '轻之国度-论坛' => {'pattern'=>'/lightnovel.cn/si','name'=>'Lightnovel','crawl_site_articles' => true,'recommend' => false},
      '读一读小说网' => {'pattern'=>'/duyidu.com/si','name'=>'Duyidu','crawl_site_articles' => true,'recommend' => false},
      '精品文學' => {'pattern'=>'/bestory.com/si','name'=>'Bestory','crawl_site_articles' => true,'recommend' => false},
      '卡提諾論壇' => {'pattern'=>'/ck101.com/si','name'=>'Ck101','crawl_site_articles' => true,'recommend' => false},
      '飛天中文' => {'pattern'=>'/gosky.net/si','name'=>'Gosky','crawl_site_articles' => true,'recommend' => false},
      '全書網' => {'pattern'=>'/quanshu.net/si','name'=>'Quanshu','crawl_site_articles' => true,'recommend' => false},
      '非凡txt' => {'pattern'=>'/fftxt.net/si','name'=>'Fftxt','crawl_site_articles' => true,'recommend' => false},
      '八拍網' => {'pattern'=>'/8apa.com/si','name'=>'Apa','crawl_site_articles' => true,'recommend' => false},
      '校園文學' => {'pattern'=>'/xybook.net/si','name'=>'Xybook','crawl_site_articles' => true,'recommend' => false},
      '思兔網' => {'pattern'=>'/book.sto.cc/si','name'=>'Sto','crawl_site_articles' => true,'recommend' => false},
      'A咖社區' => {'pattern'=>'/aka99.com/si','name'=>'Aka99','crawl_site_articles' => true,'recommend' => false},
      '言情' => {'pattern'=>'/yqhhy.cc/si','name'=>'Yqhhy','crawl_site_articles' => true,'recommend' => false},
      '棋子' => {'pattern'=>'/qizi.cc/si','name'=>'Qizi','crawl_site_articles' => true,'recommend' => false},
      '潇湘書院' => {'pattern'=>'/xxsy.net/si','name'=>'Xxsy','crawl_site_articles' => true,'recommend' => false},
      '言情小說' => {'pattern'=>'/yqxs.com/si','name'=>'Yqxs','crawl_site_articles' => true,'recommend' => false},
      '文山小說' => {'pattern'=>'/wsxs.net/si','name'=>'Wsxs','crawl_site_articles' => true,'recommend' => false},
      '天天小說' => {'pattern'=>'/ttshuo.com/si','name'=>'Ttshuo','crawl_site_articles' => true,'recommend' => false},
      '飛庫網' => {'pattern'=>'/feiku.com/si','name'=>'Feiku','crawl_site_articles' => true,'recommend' => false},
      '小說者' => {'pattern'=>'/xiaoshuozhe.com/si','name'=>'Xiaoshuozhe','crawl_site_articles' => true,'recommend' => false},
      '5800' => {'pattern'=>'/5800.cc/si','name'=>'Cc5800','crawl_site_articles' => true,'recommend' => false},
      '黃金屋中文(台灣)' => {'pattern'=>'/tw.hjwzw.com/si','name'=>'Hjwzw','crawl_site_articles' => true,'recommend' => false},
      '手打小说网' => {'pattern'=>'/xs555.com/si','name'=>'Xs555','crawl_site_articles' => true,'recommend' => false},
      '书迷楼' => {'pattern'=>'/shumilou.com/si','name'=>'Shumilou','crawl_site_articles' => true,'recommend' => false},
      '玄葫堂' => {'pattern'=>'/xuanhutang.com/si','name'=>'Xuanhutang','crawl_site_articles' => true,'recommend' => false},
      '剑侠' => {'pattern'=>'/jianxia.cc/si','name'=>'Jianxia','crawl_site_articles' => true,'recommend' => false},
      '全本小说网quanben' => {'pattern'=>'/quanben.com/si','name'=>'Quanben','crawl_site_articles' => true,'recommend' => false},
      'D586' => {'pattern'=>'/d586.com/si','name'=>'D586','crawl_site_articles' => true,'recommend' => false},
      '書吧' => {'pattern'=>'/shu88.net/si','name'=>'Shu88','crawl_site_articles' => true,'recommend' => false},
      '大文学' => {'pattern'=>'/dawenxue.net/si','name'=>'Dawenxue','crawl_site_articles' => true,'recommend' => false},
      '燃痕' => {'pattern'=>'/ranhen.net/si','name'=>'Ranhen','crawl_site_articles' => true,'recommend' => false},
      '盗墓笔记-盗墓笔记全集' => {'pattern'=>'/daomubiji.com/si','name'=>'Daomubiji','crawl_site_articles' => true,'recommend' => false},
      '御前侍卫 ' => {'pattern'=>'/yuqianshiwei.com/si','name'=>'Yuqianshiwei','crawl_site_articles' => true,'recommend' => false},
      '冒險者天堂' => {'pattern'=>'/paradise.ezla.com/si','name'=>'Paradise','crawl_site_articles' => true,'recommend' => false},
      '盗墓小说网' => {'pattern'=>'/daomuxsw.com/si','name'=>'Daomuxsw','crawl_site_articles' => true,'recommend' => false},
      '仙界小说网' => {'pattern'=>'/xianjie.me/si','name'=>'Xianjie','crawl_site_articles' => true,'recommend' => false},
      '红枫小说阅读网' => {'pattern'=>'/hfxs.com/si','name'=>'Hfxs','crawl_site_articles' => true,'recommend' => true},
      '思路客小说阅读网' => {'pattern'=>'/siluke.com/si','name'=>'Siluke','crawl_site_articles' => true,'recommend' => false},
      '明智屋小說網' => {'pattern'=>'/tw.mingzw.com/si','name'=>'Mingzw','crawl_site_articles' => true,'recommend' => false},
      '520小说' => {'pattern'=>'/520xs.com/si','name'=>'Xs520','crawl_site_articles' => true,'recommend' => false},
      '新小說吧' => {'pattern'=>'/xxs8.com/si','name'=>'Xxs8','crawl_site_articles' => true,'recommend' => false},
      '好看小說網' => {'pattern'=>'/tw.xiaoshuokan.com/si','name'=>'Xiaoshuokan','crawl_site_articles' => true,'recommend' => false},
      'uuxs' => {'pattern'=>'/uuxs.com/si','name'=>'Uuxs','crawl_site_articles' => true,'recommend' => false},
      '就爱网-小说阅读' => {'pattern'=>'/92txt.net/si','name'=>'Txt92','crawl_site_articles' => true,'recommend' => false},
      '燃文小说网' => {'pattern'=>'/ranwenxiaoshuo.com/si','name'=>'Ranwenxiaoshuo','crawl_site_articles' => true,'recommend' => false},
      '闪文书库' => {'pattern'=>'/shanwen.com/si','name'=>'Shanwen','crawl_site_articles' => true,'recommend' => false},
      '全本小说网,' => {'pattern'=>'/qbxiaoshuo.com/si','name'=>'Qbxiaoshuo','crawl_site_articles' => true,'recommend' => false},
      '玄幻小说网' => {'pattern'=>'/xhxsw.com/si','name'=>'Xhxsw','crawl_site_articles' => true,'recommend' => false},
      '波斯小说网' => {'pattern'=>'/bsxsw.com/si','name'=>'Bsxsw','crawl_site_articles' => true,'recommend' => false},
      '读趣网' => {'pattern'=>'/du7.com/si','name'=>'Du7','crawl_site_articles' => true,'recommend' => false},
      '乐文,乐文小说网' => {'pattern'=>'/lwxs.net/si','name'=>'Lwxs','crawl_site_articles' => true,'recommend' => false},
      '雅文言情小说吧' => {'pattern'=>'/yawen8.com/si','name'=>'Yawen8','crawl_site_articles' => true,'recommend' => false},
      '玫瑰言情網' => {'pattern'=>'/mgyqw.com/si','name'=>'Mgyqw','crawl_site_articles' => true,'recommend' => false},
      '微小说 日记谷日记网' => {'pattern'=>'/rijigu.com/si','name'=>'Rijigu','crawl_site_articles' => true,'recommend' => false},
      '开心文学网' => {'pattern'=>'/kxwxw.com/si','name'=>'Kxwxw','crawl_site_articles' => true,'recommend' => false},
      '大众小说网' => {'pattern'=>'/dzxsw.net/si','name'=>'Dzxsw','crawl_site_articles' => true,'recommend' => false},
      'Zwwx' => {'pattern'=>'/zwwx.com/si','name'=>'Zwwx','crawl_site_articles' => true,'recommend' => true},
      '言情小说吧' => {'pattern'=>'/xs8.cn/si','name'=>'Xs8','crawl_site_articles' => true,'recommend' => false},
      '5200小说网-吾爱小说' => {'pattern'=>'/5200xs.net/si','name'=>'Xs5200','crawl_site_articles' => true,'recommend' => false},
      '5200小说网' => {'pattern'=>'/5200.net/si','name'=>'Net5200','crawl_site_articles' => true,'recommend' => false},
      '爱尚小说网' => {'pattern'=>'/23hh.com/si','name'=>'Hh23','crawl_site_articles' => true,'recommend' => false},
      '白金小说网' => {'pattern'=>'/bjxiaoshuo.com/si','name'=>'Bjxiaoshuo','crawl_site_articles' => true,'recommend' => false},
      '飞翔鸟中文网' => {'pattern'=>'/fxnzw.com/si','name'=>'Fxnzw','crawl_site_articles' => true,'recommend' => false},
      '梦远书城' => {'pattern'=>'/my285.com/si','name'=>'My285','crawl_site_articles' => true,'recommend' => false},
      '無極小說網' => {'pattern'=>'/tw.57book.net/si','name'=>'Book57','crawl_site_articles' => true,'recommend' => false},
      '宙斯' => {'pattern'=>'/zhsxs.com/si','name'=>'Zhsxs','crawl_site_articles' => true,'recommend' => false},
      '金榜阅读' => {'pattern'=>'/jinbang.org/si','name'=>'Jinbang','crawl_site_articles' => true,'recommend' => false},
      '猎人小说' => {'pattern'=>'/orion34g.com/si','name'=>'Orion34g','crawl_site_articles' => true,'recommend' => false},
      '第五文学' => {'pattern'=>'/d5wx.com/si','name'=>'D5wx','crawl_site_articles' => true,'recommend' => false},
      '大主宰' => {'pattern'=>'/dz320.com/si','name'=>'Dz320','crawl_site_articles' => true,'recommend' => false},
      '穿越小说吧' => {'pattern'=>'/qbxs8.com/si','name'=>'Qbxs8','crawl_site_articles' => true,'recommend' => false},
      '晋江文学城' => {'pattern'=>'/jjwxc.net/si','name'=>'Jjwxc','crawl_site_articles' => true,'recommend' => false},
      '自在读小说网' => {'pattern'=>'/zizaidu.com/si','name'=>'Zizaidu','crawl_site_articles' => true,'recommend' => false},
      '滋味小说网' => {'pattern'=>'/zwxiaoshuo.com/si','name'=>'Zwxiaoshuo','crawl_site_articles' => true,'recommend' => false},
      '小说-17K小说网' => {'pattern'=>'/17k.com/si','name'=>'K17','crawl_site_articles' => true,'recommend' => false},
      '天天中文' => {'pattern'=>'/ttzw.com/si','name'=>'Ttzw','crawl_site_articles' => true,'recommend' => true},
      '最言情小说吧' => {'pattern'=>'/zuiyq.com/si','name'=>'Zuiyq','crawl_site_articles' => true,'recommend' => false},
      '六夜言情网' => {'pattern'=>'/6yzw.com/si','name'=>'Y6zw','crawl_site_articles' => true,'recommend' => false},
      '都市文学' => {'pattern'=>'/dushiwenxue.com/si','name'=>'Dushiwenxue','crawl_site_articles' => true,'recommend' => false},
      '小说者' => {'pattern'=>'/bookzx.net/si','name'=>'Bookzx','crawl_site_articles' => true,'recommend' => false},
      '免费小说阅读网-书农在线书库' => {'pattern'=>'/shunong.com/si','name'=>'Shunong','crawl_site_articles' => true,'recommend' => false},
      '书书网' => {'pattern'=>'/shushu.com.cn/si','name'=>'Shushu','crawl_site_articles' => true,'recommend' => false},
      '冠华居小说网' => {'pattern'=>'/guanhuaju.com/si','name'=>'Guanhuaju','crawl_site_articles' => true,'recommend' => false},
      '摘书小说网' => {'pattern'=>'/zhaishu.com/si','name'=>'Zhaishu','crawl_site_articles' => true,'recommend' => false},
      '书书屋' => {'pattern'=>'/shushu5.com/si','name'=>'Shushu5','crawl_site_articles' => true,'recommend' => false},
      '第二书包网' => {'pattern'=>'/shubao2.com/si','name'=>'Shubao2','crawl_site_articles' => true,'recommend' => false},
      '纵横中文网' => {'pattern'=>'/big5.zongheng.com/si','name'=>'Zongheng','crawl_site_articles' => true,'recommend' => false},
      '起點中文' => {'pattern'=>'/qidian.com/si','name'=>'Qidian','crawl_site_articles' => true,'recommend' => false},
      '燃文小说阅读网cc' => {'pattern'=>'/ranwen.cc/si','name'=>'RanwenCc','crawl_site_articles' => true,'recommend' => false},
      '海天中文' => {'pattern'=>'/htzw.net/si','name'=>'Htzw','crawl_site_articles' => true,'recommend' => false},
      'YY書屋' => {'pattern'=>'/bbs.yys5.com/si','name'=>'Yys5','crawl_site_articles' => true,'recommend' => false},
      '言情小屋' => {'pattern'=>'/yqxw.net/si','name'=>'Yqxw','crawl_site_articles' => true,'recommend' => false},
      '天天书吧' => {'pattern'=>'/ttshu8.com/si','name'=>'Ttshu8','crawl_site_articles' => true,'recommend' => false},
      'TXT小说下载' => {'pattern'=>'/txtbbs.com/si','name'=>'Txtbbs','crawl_site_articles' => true,'recommend' => false},

      '全本書庫' => {'pattern'=>'/qbshuku.com/si','name'=>'Qbshuku','crawl_site_articles' => false,'recommend' => false},
      '九品文学' => {'pattern'=>'/tw.9pwx.com/si','name'=>'P9wx','crawl_site_articles' => false,'recommend' => false},
      '艳腾中文' => {'pattern'=>'/yantengzw.com/si','name'=>'Yantengzw','crawl_site_articles' => false,'recommend' => false},
      '腾讯原创' => {'pattern'=>'/book.qq.com/si','name'=>'BookQq','crawl_site_articles' => false,'recommend' => false},
      '四海网' => {'pattern'=>'/4hw.com.cn/si','name'=>'Hw4','crawl_site_articles' => false,'recommend' => false},
      '热门小说阅读' => {'pattern'=>'/52buk.com/si','name'=>'Buk52','crawl_site_articles' => false,'recommend' => false},
      '阿甘小说网' => {'pattern'=>'/8535.org/si','name'=>'Org8535','crawl_site_articles' => false,'recommend' => false},
      '看啦又看小说网' => {'pattern'=>'/k6uk.com/si','name'=>'K6uk','crawl_site_articles' => false,'recommend' => false},
      '无错小说网' => {'pattern'=>'/wcxiaoshuo.com/si','name'=>'Wcxiaoshuo','crawl_site_articles' => false,'recommend' => false},
      'u8小说' => {'pattern'=>'/u8xs.com/si','name'=>'U8xs','crawl_site_articles' => false,'recommend' => false},
      '六叶中文网' => {'pattern'=>'/6ycn.net/si','name'=>'Ycn6','crawl_site_articles' => false,'recommend' => false},
      '108小说网' => {'pattern'=>'/book108.com/si','name'=>'Book108','crawl_site_articles' => false,'recommend' => false},
      '谷粒网' => {'pattern'=>'/guli.cc/si','name'=>'Guli','crawl_site_articles' => true,'recommend' => false},
      '酷书库' => {'pattern'=>'/kushuku.com/si','name'=>'Kushuku','crawl_site_articles' => false,'recommend' => false},
      '云书阁' => {'pattern'=>'/yunshuge.com/si','name'=>'Yunshuge','crawl_site_articles' => false,'recommend' => false},
      '迪文小说网' => {'pattern'=>'/dwxs.net/si','name'=>'Dwxs','crawl_site_articles' => false,'recommend' => false},
      '燃文吧' => {'pattern'=>'/ranwenba.net/si','name'=>'Ranwenba','crawl_site_articles' => false,'recommend' => false},
      '二百五书院' => {'pattern'=>'/250sy.com/si','name'=>'Sy250','crawl_site_articles' => false,'recommend' => false},
      '天天书屋' => {'pattern'=>'/ttshu.com/si','name'=>'Ttshu','crawl_site_articles' => false,'recommend' => false}
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