# coding : utf-8
require 'open-uri'
require 'nokogiri'
require 'json'
require 'parallel'
require 'pp'
require 'ruby-progressbar'
require 'retryable'

urls = %w(
http://dic.nicovideo.jp/a/%E3%82%A4%E3%83%B4%E3%83%BB%E3%82%B5%E3%83%B3%E3%82%BF%E3%82%AF%E3%83%AD%E3%83%BC%E3%82%B9
http://dic.nicovideo.jp/a/%E3%82%AD%E3%83%A3%E3%82%B7%E3%83%BC%E3%83%BB%E3%82%B0%E3%83%A9%E3%83%8F%E3%83%A0
http://dic.nicovideo.jp/a/%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC%E3%83%88%E3%83%AC%E3%83%BC%E3%83%8A%E3%83%BC
http://dic.nicovideo.jp/a/%E3%83%A1%E3%82%A2%E3%83%AA%E3%83%BC%E3%83%BB%E3%82%B3%E3%82%AF%E3%83%A9%E3%83%B3
http://dic.nicovideo.jp/a/%E3%83%AB%E3%83%BC%E3%82%AD%E3%83%BC%E3%83%88%E3%83%AC%E3%83%BC%E3%83%8A%E3%83%BC
http://dic.nicovideo.jp/a/%E4%B8%80%E3%83%8E%E7%80%AC%E5%BF%97%E5%B8%8C
http://dic.nicovideo.jp/a/%E4%B8%89%E5%A5%BD%E7%B4%97%E5%8D%97
http://dic.nicovideo.jp/a/%E4%B8%89%E6%9D%91%E3%81%8B%E3%81%AA%E5%AD%90
http://dic.nicovideo.jp/a/%E4%B8%89%E8%88%B9%E7%BE%8E%E5%84%AA
http://dic.nicovideo.jp/a/%E4%B8%8A%E6%9D%A1%E6%98%A5%E8%8F%9C
http://dic.nicovideo.jp/a/%E4%B8%8A%E7%94%B0%E9%88%B4%E5%B8%86
http://dic.nicovideo.jp/a/%E4%B8%A6%E6%9C%A8%E8%8A%BD%E8%A1%A3%E5%AD%90
http://dic.nicovideo.jp/a/%E4%B8%AD%E9%87%8E%E6%9C%89%E9%A6%99
http://dic.nicovideo.jp/a/%E4%B8%B9%E7%BE%BD%E4%BB%81%E7%BE%8E
http://dic.nicovideo.jp/a/%E4%B9%99%E5%80%89%E6%82%A0%E8%B2%B4
http://dic.nicovideo.jp/a/%E4%BA%8C%E5%AE%AE%E9%A3%9B%E9%B3%A5
http://dic.nicovideo.jp/a/%E4%BA%94%E5%8D%81%E5%B5%90%E9%9F%BF%E5%AD%90
http://dic.nicovideo.jp/a/%E4%BA%95%E6%9D%91%E9%9B%AA%E8%8F%9C
http://dic.nicovideo.jp/a/%E4%BB%8A%E4%BA%95%E5%8A%A0%E5%A5%88
http://dic.nicovideo.jp/a/%E4%BB%99%E5%B4%8E%E6%81%B5%E7%A3%A8
http://dic.nicovideo.jp/a/%E4%BC%8A%E9%9B%86%E9%99%A2%E6%83%A0
http://dic.nicovideo.jp/a/%E4%BD%90%E3%80%85%E6%9C%A8%E5%8D%83%E6%9E%9D
http://dic.nicovideo.jp/a/%E4%BD%90%E4%B9%85%E9%96%93%E3%81%BE%E3%82%86
http://dic.nicovideo.jp/a/%E4%BD%90%E5%9F%8E%E9%9B%AA%E7%BE%8E
http://dic.nicovideo.jp/a/%E4%BE%9D%E7%94%B0%E8%8A%B3%E4%B9%83
http://dic.nicovideo.jp/a/%E5%85%AB%E7%A5%9E%E3%83%9E%E3%82%AD%E3%83%8E
http://dic.nicovideo.jp/a/%E5%85%B5%E8%97%A4%E3%83%AC%E3%83%8A
http://dic.nicovideo.jp/a/%E5%86%B4%E5%B3%B6%E6%B8%85%E7%BE%8E
http://dic.nicovideo.jp/a/%E5%89%8D%E5%B7%9D%E3%81%BF%E3%81%8F
http://dic.nicovideo.jp/a/%E5%8C%97%E5%B7%9D%E7%9C%9F%E5%B0%8B
http://dic.nicovideo.jp/a/%E5%8C%97%E6%9D%A1%E5%8A%A0%E8%93%AE
http://dic.nicovideo.jp/a/%E5%8D%81%E6%99%82%E6%84%9B%E6%A2%A8
http://dic.nicovideo.jp/a/%E5%8D%97%E6%9D%A1%E5%85%89
http://dic.nicovideo.jp/a/%E5%8E%9F%E7%94%B0%E7%BE%8E%E4%B8%96
http://dic.nicovideo.jp/a/%E5%8F%8A%E5%B7%9D%E9%9B%AB
http://dic.nicovideo.jp/a/%E5%8F%8C%E8%91%89%E6%9D%8F
http://dic.nicovideo.jp/a/%E5%8F%A4%E6%BE%A4%E9%A0%BC%E5%AD%90
http://dic.nicovideo.jp/a/%E5%8F%A4%E8%B3%80%E5%B0%8F%E6%98%A5
http://dic.nicovideo.jp/a/%E5%90%89%E5%B2%A1%E6%B2%99%E7%B4%80
http://dic.nicovideo.jp/a/%E5%90%91%E4%BA%95%E6%8B%93%E6%B5%B7
http://dic.nicovideo.jp/a/%E5%92%8C%E4%B9%85%E4%BA%95%E7%95%99%E7%BE%8E
http://dic.nicovideo.jp/a/%E5%96%9C%E5%A4%9A%E6%97%A5%E8%8F%9C%E5%AD%90
http://dic.nicovideo.jp/a/%E5%96%9C%E5%A4%9A%E8%A6%8B%E6%9F%9A
http://dic.nicovideo.jp/a/%E5%9C%9F%E5%B1%8B%E4%BA%9C%E5%AD%90
http://dic.nicovideo.jp/a/%E5%9F%8E%E3%83%B6%E5%B4%8E%E7%BE%8E%E5%98%89
http://dic.nicovideo.jp/a/%E5%9F%8E%E3%83%B6%E5%B4%8E%E8%8E%89%E5%98%89
http://dic.nicovideo.jp/a/%E5%A0%80%E8%A3%95%E5%AD%90
http://dic.nicovideo.jp/a/%E5%A1%A9%E8%A6%8B%E5%91%A8%E5%AD%90
http://dic.nicovideo.jp/a/%E5%A4%9A%E7%94%B0%E6%9D%8E%E8%A1%A3%E8%8F%9C
http://dic.nicovideo.jp/a/%E5%A4%A7%E5%8E%9F%E3%81%BF%E3%81%A1%E3%82%8B
http://dic.nicovideo.jp/a/%E5%A4%A7%E5%92%8C%E4%BA%9C%E5%AD%A3
http://dic.nicovideo.jp/a/%E5%A4%A7%E6%A7%BB%E5%94%AF
http://dic.nicovideo.jp/a/%E5%A4%A7%E6%B2%BC%E3%81%8F%E3%82%8B%E3%81%BF
http://dic.nicovideo.jp/a/%E5%A4%A7%E7%9F%B3%E6%B3%89
http://dic.nicovideo.jp/a/%E5%A4%A7%E8%A5%BF%E7%94%B1%E9%87%8C%E5%AD%90
http://dic.nicovideo.jp/a/%E5%A4%AA%E7%94%B0%E5%84%AA
http://dic.nicovideo.jp/a/%E5%A5%A5%E5%B1%B1%E6%B2%99%E7%B9%94
http://dic.nicovideo.jp/a/%E5%A7%AB%E5%B7%9D%E5%8F%8B%E7%B4%80
http://dic.nicovideo.jp/a/%E5%AE%89%E6%96%8E%E9%83%BD
http://dic.nicovideo.jp/a/%E5%AE%89%E9%83%A8%E8%8F%9C%E3%80%85
http://dic.nicovideo.jp/a/%E5%AE%AE%E6%9C%AC%E3%83%95%E3%83%AC%E3%83%87%E3%83%AA%E3%82%AB
http://dic.nicovideo.jp/a/%E5%B0%8F%E5%AE%A4%E5%8D%83%E5%A5%88%E7%BE%8E
http://dic.nicovideo.jp/a/%E5%B0%8F%E6%97%A5%E5%90%91%E7%BE%8E%E7%A9%82
http://dic.nicovideo.jp/a/%E5%B0%8F%E6%97%A9%E5%B7%9D%E7%B4%97%E6%9E%9D
http://dic.nicovideo.jp/a/%E5%B0%8F%E6%9D%BE%E4%BC%8A%E5%90%B9
http://dic.nicovideo.jp/a/%E5%B0%8F%E9%96%A2%E9%BA%97%E5%A5%88
http://dic.nicovideo.jp/a/%E5%B2%A1%E5%B4%8E%E6%B3%B0%E8%91%89
http://dic.nicovideo.jp/a/%E5%B2%B8%E9%83%A8%E5%BD%A9%E8%8F%AF
http://dic.nicovideo.jp/a/%E5%B3%B6%E6%9D%91%E5%8D%AF%E6%9C%88
http://dic.nicovideo.jp/a/%E5%B7%9D%E5%B3%B6%E7%91%9E%E6%A8%B9
http://dic.nicovideo.jp/a/%E5%B7%A5%E8%97%A4%E5%BF%8D
http://dic.nicovideo.jp/a/%E5%B8%82%E5%8E%9F%E4%BB%81%E5%A5%88
http://dic.nicovideo.jp/a/%E6%84%9B%E9%87%8E%E6%B8%9A
http://dic.nicovideo.jp/a/%E6%88%90%E5%AE%AE%E7%94%B1%E6%84%9B
http://dic.nicovideo.jp/a/%E6%8C%81%E7%94%B0%E4%BA%9C%E9%87%8C%E6%B2%99
http://dic.nicovideo.jp/a/%E6%96%89%E8%97%A4%E6%B4%8B%E5%AD%90
http://dic.nicovideo.jp/a/%E6%96%B0%E7%94%B0%E7%BE%8E%E6%B3%A2
http://dic.nicovideo.jp/a/%E6%97%A5%E4%B8%8B%E9%83%A8%E8%8B%A5%E8%91%89
http://dic.nicovideo.jp/a/%E6%97%A5%E9%87%8E%E8%8C%9C
http://dic.nicovideo.jp/a/%E6%97%A9%E5%9D%82%E7%BE%8E%E7%8E%B2
http://dic.nicovideo.jp/a/%E6%98%9F%E8%BC%9D%E5%AD%90
http://dic.nicovideo.jp/a/%E6%9C%88%E5%AE%AE%E9%9B%85
http://dic.nicovideo.jp/a/%E6%9C%89%E6%B5%A6%E6%9F%91%E5%A5%88
http://dic.nicovideo.jp/a/%E6%9C%8D%E9%83%A8%E7%9E%B3%E5%AD%90
http://dic.nicovideo.jp/a/%E6%9C%9B%E6%9C%88%E8%81%96
http://dic.nicovideo.jp/a/%E6%9C%A8%E5%A0%B4%E7%9C%9F%E5%A5%88%E7%BE%8E
http://dic.nicovideo.jp/a/%E6%9C%A8%E6%9D%91%E5%A4%8F%E6%A8%B9
http://dic.nicovideo.jp/a/%E6%9C%AC%E7%94%B0%E6%9C%AA%E5%A4%AE
http://dic.nicovideo.jp/a/%E6%9D%89%E5%9D%82%E6%B5%B7
http://dic.nicovideo.jp/a/%E6%9D%91%E4%B8%8A%E5%B7%B4
http://dic.nicovideo.jp/a/%E6%9D%91%E6%9D%BE%E3%81%95%E3%81%8F%E3%82%89
http://dic.nicovideo.jp/a/%E6%9D%B1%E9%83%B7%E3%81%82%E3%81%84
http://dic.nicovideo.jp/a/%E6%9D%BE%E5%8E%9F%E6%97%A9%E8%80%B6
http://dic.nicovideo.jp/a/%E6%9D%BE%E5%B0%BE%E5%8D%83%E9%B6%B4
http://dic.nicovideo.jp/a/%E6%9D%BE%E5%B1%B1%E4%B9%85%E7%BE%8E%E5%AD%90
http://dic.nicovideo.jp/a/%E6%9D%BE%E6%9C%AC%E6%B2%99%E7%90%86%E5%A5%88
http://dic.nicovideo.jp/a/%E6%9D%BE%E6%B0%B8%E6%B6%BC
http://dic.nicovideo.jp/a/%E6%9F%8A%E5%BF%97%E4%B9%83
http://dic.nicovideo.jp/a/%E6%9F%B3%E6%B8%85%E8%89%AF
http://dic.nicovideo.jp/a/%E6%9F%B3%E7%80%AC%E7%BE%8E%E7%94%B1%E7%B4%80
http://dic.nicovideo.jp/a/%E6%A0%97%E5%8E%9F%E3%83%8D%E3%83%8D
http://dic.nicovideo.jp/a/%E6%A1%83%E4%BA%95%E3%81%82%E3%81%9A%E3%81%8D
http://dic.nicovideo.jp/a/%E6%A1%90%E7%94%9F%E3%81%A4%E3%81%8B%E3%81%95
http://dic.nicovideo.jp/a/%E6%A1%90%E9%87%8E%E3%82%A2%E3%83%A4
http://dic.nicovideo.jp/a/%E6%A2%85%E6%9C%A8%E9%9F%B3%E8%91%89
http://dic.nicovideo.jp/a/%E6%A3%9F%E6%96%B9%E6%84%9B%E6%B5%B7
http://dic.nicovideo.jp/a/%E6%A3%AE%E4%B9%85%E4%BF%9D%E4%B9%83%E3%80%85
http://dic.nicovideo.jp/a/%E6%A5%8A%E8%8F%B2%E8%8F%B2
http://dic.nicovideo.jp/a/%E6%A6%8A%E5%8E%9F%E9%87%8C%E7%BE%8E
http://dic.nicovideo.jp/a/%E6%A7%99%E5%8E%9F%E5%BF%97%E4%BF%9D
http://dic.nicovideo.jp/a/%E6%A8%AA%E5%B1%B1%E5%8D%83%E4%BD%B3
http://dic.nicovideo.jp/a/%E6%A9%98%E3%81%82%E3%82%8A%E3%81%99
http://dic.nicovideo.jp/a/%E6%AB%BB%E4%BA%95%E6%A1%83%E8%8F%AF
http://dic.nicovideo.jp/a/%E6%B0%8F%E5%AE%B6%E3%82%80%E3%81%A4%E3%81%BF
http://dic.nicovideo.jp/a/%E6%B0%B4%E6%9C%A8%E8%81%96%E4%BE%86
http://dic.nicovideo.jp/a/%E6%B0%B4%E6%9C%AC%E3%82%86%E3%81%8B%E3%82%8A
http://dic.nicovideo.jp/a/%E6%B0%B4%E9%87%8E%E7%BF%A0
http://dic.nicovideo.jp/a/%E6%B1%9F%E4%B8%8A%E6%A4%BF
http://dic.nicovideo.jp/a/%E6%B1%A0%E8%A2%8B%E6%99%B6%E8%91%89
http://dic.nicovideo.jp/a/%E6%B2%A2%E7%94%B0%E9%BA%BB%E7%90%86%E8%8F%9C
http://dic.nicovideo.jp/a/%E6%B5%85%E5%88%A9%E4%B8%83%E6%B5%B7
http://dic.nicovideo.jp/a/%E6%B5%85%E9%87%8E%E9%A2%A8%E9%A6%99
http://dic.nicovideo.jp/a/%E6%B5%9C%E5%8F%A3%E3%81%82%E3%82%84%E3%82%81
http://dic.nicovideo.jp/a/%E6%B5%9C%E5%B7%9D%E6%84%9B%E7%B5%90%E5%A5%88
http://dic.nicovideo.jp/a/%E6%B5%B7%E8%80%81%E5%8E%9F%E8%8F%9C%E5%B8%86
http://dic.nicovideo.jp/a/%E6%B6%BC%E5%AE%AE%E6%98%9F%E8%8A%B1
http://dic.nicovideo.jp/a/%E6%B8%8B%E8%B0%B7%E5%87%9B
http://dic.nicovideo.jp/a/%E7%80%AC%E5%90%8D%E8%A9%A9%E7%B9%94
http://dic.nicovideo.jp/a/%E7%89%87%E6%A1%90%E6%97%A9%E8%8B%97
http://dic.nicovideo.jp/a/%E7%99%BD%E5%9D%82%E5%B0%8F%E6%A2%85
http://dic.nicovideo.jp/a/%E7%99%BD%E8%8F%8A%E3%81%BB%E3%81%9F%E3%82%8B
http://dic.nicovideo.jp/a/%E7%9A%84%E5%A0%B4%E6%A2%A8%E6%B2%99
http://dic.nicovideo.jp/a/%E7%9B%B8%E5%8E%9F%E9%9B%AA%E4%B9%83
http://dic.nicovideo.jp/a/%E7%9B%B8%E5%B7%9D%E5%8D%83%E5%A4%8F
http://dic.nicovideo.jp/a/%E7%9B%B8%E8%91%89%E5%A4%95%E7%BE%8E
http://dic.nicovideo.jp/a/%E7%9B%B8%E9%A6%AC%E5%A4%8F%E7%BE%8E
http://dic.nicovideo.jp/a/%E7%9C%9F%E9%8D%8B%E3%81%84%E3%81%A4%E3%81%8D
http://dic.nicovideo.jp/a/%E7%9F%A2%E5%8F%A3%E7%BE%8E%E7%BE%BD
http://dic.nicovideo.jp/a/%E7%A5%9E%E5%B4%8E%E8%98%AD%E5%AD%90
http://dic.nicovideo.jp/a/%E7%A5%9E%E8%B0%B7%E5%A5%88%E7%B7%92
http://dic.nicovideo.jp/a/%E7%A6%8F%E5%B1%B1%E8%88%9E
http://dic.nicovideo.jp/a/%E7%AF%A0%E5%8E%9F%E7%A4%BC
http://dic.nicovideo.jp/a/%E7%B5%90%E5%9F%8E%E6%99%B4
http://dic.nicovideo.jp/a/%E7%B6%BE%E7%80%AC%E7%A9%82%E4%B9%83%E9%A6%99
http://dic.nicovideo.jp/a/%E7%B7%92%E6%96%B9%E6%99%BA%E7%B5%B5%E9%87%8C
http://dic.nicovideo.jp/a/%E8%84%87%E5%B1%B1%E7%8F%A0%E7%BE%8E
http://dic.nicovideo.jp/a/%E8%8B%A5%E6%9E%97%E6%99%BA%E9%A6%99
http://dic.nicovideo.jp/a/%E8%8D%92%E6%9C%A8%E6%AF%94%E5%A5%88
http://dic.nicovideo.jp/a/%E8%97%A4%E5%8E%9F%E8%82%87
http://dic.nicovideo.jp/a/%E8%97%A4%E5%B1%85%E6%9C%8B
http://dic.nicovideo.jp/a/%E8%97%A4%E6%9C%AC%E9%87%8C%E5%A5%88
http://dic.nicovideo.jp/a/%E8%A1%9B%E8%97%A4%E7%BE%8E%E7%B4%97%E5%B8%8C
http://dic.nicovideo.jp/a/%E8%A5%BF%E5%9C%92%E5%AF%BA%E7%90%B4%E6%AD%8C
http://dic.nicovideo.jp/a/%E8%A5%BF%E5%B3%B6%E6%AB%82
http://dic.nicovideo.jp/a/%E8%A5%BF%E5%B7%9D%E4%BF%9D%E5%A5%88%E7%BE%8E
http://dic.nicovideo.jp/a/%E8%AB%B8%E6%98%9F%E3%81%8D%E3%82%89%E3%82%8A
http://dic.nicovideo.jp/a/%E8%B2%A1%E5%89%8D%E6%99%82%E5%AD%90
http://dic.nicovideo.jp/a/%E8%B5%A4%E5%9F%8E%E3%81%BF%E3%82%8A%E3%81%82
http://dic.nicovideo.jp/a/%E8%B5%A4%E8%A5%BF%E7%91%9B%E6%A2%A8%E8%8F%AF
http://dic.nicovideo.jp/a/%E8%BC%BF%E6%B0%B4%E5%B9%B8%E5%AD%90
http://dic.nicovideo.jp/a/%E9%80%9F%E6%B0%B4%E5%A5%8F
http://dic.nicovideo.jp/a/%E9%81%8A%E4%BD%90%E3%81%93%E3%81%9A%E3%81%88
http://dic.nicovideo.jp/a/%E9%81%93%E6%98%8E%E5%AF%BA%E6%AD%8C%E9%88%B4
http://dic.nicovideo.jp/a/%E9%87%8E%E3%80%85%E6%9D%91%E3%81%9D%E3%82%89
http://dic.nicovideo.jp/a/%E9%95%B7%E5%AF%8C%E8%93%AE%E5%AE%9F
http://dic.nicovideo.jp/a/%E9%96%93%E4%B8%AD%E7%BE%8E%E9%87%8C
http://dic.nicovideo.jp/a/%E9%96%A2%E8%A3%95%E7%BE%8E
http://dic.nicovideo.jp/a/%E9%9B%A3%E6%B3%A2%E7%AC%91%E7%BE%8E
http://dic.nicovideo.jp/a/%E9%A6%96%E8%97%A4%E8%91%B5
http://dic.nicovideo.jp/a/%E9%AB%98%E5%9E%A3%E6%A5%93
http://dic.nicovideo.jp/a/%E9%AB%98%E5%B3%AF%E3%81%AE%E3%81%82
http://dic.nicovideo.jp/a/%E9%AB%98%E6%A3%AE%E8%97%8D%E5%AD%90
http://dic.nicovideo.jp/a/%E9%AB%98%E6%A9%8B%E7%A4%BC%E5%AD%90
http://dic.nicovideo.jp/a/%E9%B7%B9%E5%AF%8C%E5%A3%AB%E8%8C%84%E5%AD%90
http://dic.nicovideo.jp/a/%E9%B7%BA%E6%B2%A2%E6%96%87%E9%A6%99
http://dic.nicovideo.jp/a/%E9%BB%92%E5%B7%9D%E5%8D%83%E7%A7%8B
http://dic.nicovideo.jp/a/%E9%BE%8D%E5%B4%8E%E8%96%AB
http://dic.nicovideo.jp/a/%E3%83%A9%E3%82%A4%E3%83%A9%28%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC%29
http://dic.nicovideo.jp/a/%E6%A4%8E%E5%90%8D%E6%B3%95%E5%AD%90(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%82%A2%E3%83%8A%E3%82%B9%E3%82%BF%E3%82%B7%E3%82%A2(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%82%AF%E3%83%A9%E3%83%AA%E3%82%B9(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%82%B1%E3%82%A4%E3%83%88(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%83%88%E3%83%AC%E3%83%BC%E3%83%8A%E3%83%BC(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%83%8A%E3%82%BF%E3%83%BC%E3%83%AA%E3%82%A2(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%83%98%E3%83%AC%E3%83%B3(%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC)
http://dic.nicovideo.jp/a/%E3%83%99%E3%83%86%E3%83%A9%E3%83%B3%E3%83%88%E3%83%AC%E3%83%BC%E3%83%8A%E3%83%BC%28%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC%29
http://dic.nicovideo.jp/a/%E4%BD%90%E8%97%A4%E5%BF%83%28%E3%82%A2%E3%82%A4%E3%83%89%E3%83%AB%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC%29
)

def parse url
  charset,html = open(url) do |f|
    [f.charset, f.read]
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)
  name = doc.css('title').text
  trs = doc.css('#article tbody > tr')

  val = trs[3..12].map.with_index do |tr, i|
    begin
      tr.css('td')[0].text
    rescue
      puts name + ':' + i.to_s
      next nil
    end
  end

  type = trs[2].css('td')[1].text rescue puts(name + ':type')

  hash = Hash[
    *%w(age birthday height weight bwh bloodtype hobby handedness birthplace cv)
    .zip(val).flatten]
  hash['type'] = type
  hash['name'] = name
  hash
end


THREADS = 5
hashes = Parallel.map(urls, in_threads: THREADS, progress: 'downloading') do |url|
  Retryable.retryable do
    parse url
  end
end

open('cinderella.json', 'w:utf-8') {|f| f.write JSON.pretty_generate(hashes) }
