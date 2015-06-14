# codin : utf-8

require 'json'
require 'pp'

data = JSON.parse open('cinderella.json').read
data = data.map do |i| 
  raise i['name'] unless i['type'] =~ /クール|パッション|キュート/
  $&
end

pp data

