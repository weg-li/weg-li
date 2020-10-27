require 'byebug'
data = File.read('TBKAT.DAT')
data[2..-3].split("\r.").each_with_index do |d, i|
  lines = d.split("\r")
  name = lines.shift
  puts name
  File.write("data/#{name}.csv", lines.map(&:strip).join("\n"))
end
