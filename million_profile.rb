# coding : utf-8
require 'open-uri'
require 'nokogiri'
require 'json'
require 'parallel'
require 'pp'
require 'ruby-progressbar'

urls = %w(
http://www.millionlive.com/index.php?%E5%A4%A9%E6%B5%B7%E6%98%A5%E9%A6%99
http://www.millionlive.com/index.php?%E6%98%A5%E6%97%A5%E6%9C%AA%E6%9D%A5
http://www.millionlive.com/index.php?%E5%A6%82%E6%9C%88%E5%8D%83%E6%97%A9
http://www.millionlive.com/index.php?%E6%9C%A8%E4%B8%8B%E3%81%B2%E3%81%AA%E3%81%9F
http://www.millionlive.com/index.php?%E5%9B%9B%E6%9D%A1%E8%B2%B4%E9%9F%B3
http://www.millionlive.com/index.php?%E3%82%B8%E3%83%A5%E3%83%AA%E3%82%A2
http://www.millionlive.com/index.php?%E9%AB%98%E5%B1%B1%E7%B4%97%E4%BB%A3%E5%AD%90
http://www.millionlive.com/index.php?%E7%94%B0%E4%B8%AD%E7%90%B4%E8%91%89
http://www.millionlive.com/index.php?%E5%A4%A9%E7%A9%BA%E6%A9%8B%E6%9C%8B%E8%8A%B1
http://www.millionlive.com/index.php?%E7%AE%B1%E5%B4%8E%E6%98%9F%E6%A2%A8%E8%8A%B1
http://www.millionlive.com/index.php?%E6%9D%BE%E7%94%B0%E4%BA%9C%E5%88%A9%E6%B2%99
http://www.millionlive.com/index.php?%E4%B8%89%E6%B5%A6%E3%81%82%E3%81%9A%E3%81%95
http://www.millionlive.com/index.php?%E6%B0%B4%E7%80%AC%E4%BC%8A%E7%B9%94
http://www.millionlive.com/index.php?%E6%9C%80%E4%B8%8A%E9%9D%99%E9%A6%99
http://www.millionlive.com/index.php?%E6%9C%9B%E6%9C%88%E6%9D%8F%E5%A5%88
http://www.millionlive.com/index.php?%E7%9F%A2%E5%90%B9%E5%8F%AF%E5%A5%88
http://www.millionlive.com/index.php?%E3%82%A8%E3%83%9F%E3%83%AA%E3%83%BC%20%E3%82%B9%E3%83%81%E3%83%A5%E3%82%A2%E3%83%BC%E3%83%88
http://www.millionlive.com/index.php?%E5%A4%A7%E7%A5%9E%E7%92%B0
http://www.millionlive.com/index.php?%E6%88%91%E9%82%A3%E8%A6%87%E9%9F%BF
http://www.millionlive.com/index.php?%E8%8F%8A%E5%9C%B0%E7%9C%9F
http://www.millionlive.com/index.php?%E5%8C%97%E4%B8%8A%E9%BA%97%E8%8A%B1
http://www.millionlive.com/index.php?%E9%AB%98%E5%9D%82%E6%B5%B7%E7%BE%8E
http://www.millionlive.com/index.php?%E4%BD%90%E7%AB%B9%E7%BE%8E%E5%A5%88%E5%AD%90
http://www.millionlive.com/index.php?%E5%B3%B6%E5%8E%9F%E3%82%A8%E3%83%AC%E3%83%8A
http://www.millionlive.com/index.php?%E9%AB%98%E6%A7%BB%E3%82%84%E3%82%88%E3%81%84
http://www.millionlive.com/index.php?%E6%B0%B8%E5%90%89%E6%98%B4
http://www.millionlive.com/index.php?%E9%87%8E%E3%80%85%E5%8E%9F%E8%8C%9C
http://www.millionlive.com/index.php?%E9%A6%AC%E5%A0%B4%E3%81%93%E3%81%AE%E3%81%BF
http://www.millionlive.com/index.php?%E7%A6%8F%E7%94%B0%E3%81%AE%E3%82%8A%E5%AD%90
http://www.millionlive.com/index.php?%E8%88%9E%E6%B5%9C%E6%AD%A9
http://www.millionlive.com/index.php?%E7%9C%9F%E5%A3%81%E7%91%9E%E5%B8%8C
http://www.millionlive.com/index.php?%E7%99%BE%E7%80%AC%E8%8E%89%E7%B7%92
http://www.millionlive.com/index.php?%E6%A8%AA%E5%B1%B1%E5%A5%88%E7%B7%92
http://www.millionlive.com/index.php?%E7%A7%8B%E6%9C%88%E5%BE%8B%E5%AD%90
http://www.millionlive.com/index.php?%E4%BC%8A%E5%90%B9%E7%BF%BC
http://www.millionlive.com/index.php?%E5%8C%97%E6%B2%A2%E5%BF%97%E4%BF%9D
http://www.millionlive.com/index.php?%E7%AF%A0%E5%AE%AE%E5%8F%AF%E6%86%90
http://www.millionlive.com/index.php?%E5%91%A8%E9%98%B2%E6%A1%83%E5%AD%90
http://www.millionlive.com/index.php?%E5%BE%B3%E5%B7%9D%E3%81%BE%E3%81%A4%E3%82%8A
http://www.millionlive.com/index.php?%E6%89%80%E6%81%B5%E7%BE%8E
http://www.millionlive.com/index.php?%E8%B1%8A%E5%B7%9D%E9%A2%A8%E8%8A%B1
http://www.millionlive.com/index.php?%E4%B8%AD%E8%B0%B7%E8%82%B2
http://www.millionlive.com/index.php?%E4%B8%83%E5%B0%BE%E7%99%BE%E5%90%88%E5%AD%90
http://www.millionlive.com/index.php?%E4%BA%8C%E9%9A%8E%E5%A0%82%E5%8D%83%E9%B6%B4
http://www.millionlive.com/index.php?%E8%90%A9%E5%8E%9F%E9%9B%AA%E6%AD%A9
http://www.millionlive.com/index.php?%E5%8F%8C%E6%B5%B7%E4%BA%9C%E7%BE%8E
http://www.millionlive.com/index.php?%E5%8F%8C%E6%B5%B7%E7%9C%9F%E7%BE%8E
http://www.millionlive.com/index.php?%E6%98%9F%E4%BA%95%E7%BE%8E%E5%B8%8C
http://www.millionlive.com/index.php?%E5%AE%AE%E5%B0%BE%E7%BE%8E%E4%B9%9F
http://www.millionlive.com/index.php?%E4%BC%B4%E7%94%B0%E8%B7%AF%E5%AD%90%28%E3%83%AD%E3%82%B3%29
)

THREADS = 10
hashes = Parallel.map(urls, in_threads: THREADS, progress: 'downloading') do |url|

  charset,html = open(url) do |f|
    [f.charset, f.read]
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)
  val = doc.css('#main_content > div:nth-child(11) > table > tbody > tr > td').drop(2).map do |e|
    e.text
  end

  name = doc.css('#main_content > h2.sub').text.strip
  type = doc.css("#main_content th.style_th").find{|th| th.text == '属性'}.next.text

  hash = Hash[*%w(cv age birth height weight bwh cup bloodtype hobby special like color)
          .zip(val).flatten]
  hash['name'] = name
  hash['type'] = type
  hash
end

open('million_profile.json', 'w:utf-8') {|f| f.write JSON.pretty_generate(hashes) }



