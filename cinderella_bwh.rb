# codin : utf-8
require 'json'
require 'nyaplot'
require 'pp'

TYPES = %w(クール パッション キュート)

def box data, idx
  hash = Hash[*data.map{|key, value| [key, value.map{|v| v[idx] }]}.flatten(1)]
  df = Nyaplot::DataFrame.new(hash)
  plot = Nyaplot::Plot.new
  plot.add_with_df(df, :box, *TYPES)
  plot
end

data = JSON.parse open('cinderella.json', "r:utf-8").read
data = data.map do |i| 
  next nil unless i['bwh'] =~ /(\d+)-(\d+)-(\d+)/
  bust, weist, hip = [$1, $2, $3].map(&:to_i)
  i['name'] unless i['type'] =~ /#{TYPES.join("|")}/
  type = $&
  [type, bust, weist, hip]
end.compact

data = Hash[*data.sort_by{|d| d[0]}.chunk{|d| d[0]}.to_a.flatten(1)]

b = box data, 1
h = box data, 2
w = box data, 3

frame = Nyaplot::Frame.new
frame.add b
frame.add h
frame.add w

frame.export_html "cinderella_bhw.html"
