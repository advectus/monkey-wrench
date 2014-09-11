require "csv"
require 'iconv'
require "ripl"

# show me every row of data in every table

abort "usage: ruby mdb_spitball.rb workspace" if ARGV.length < 1

workspace = "#{ARGV[0]}"
puts "Start"

file = STDIN.gets.chomp

count = 0
ic = Iconv.new('UTF-8//IGNORE', 'UTF-8') #Invalid byte sequenece string conversion
accepted = Dir["#{workspace}**/*"].reject{|file| not file.include? ".mdb"}.collect{|file| {:id=>count+=1, :file=>file.gsub("#{workspace}","")}}
puts accepted

puts "\nEnter file id:"
file_id = STDIN.gets.chomp

puts accepted[(file_id.to_i-1)][:file]

database = []
`mdb-tables "#{workspace }#{accepted[(file_id.to_i-1)][:file]}"`.split(" ").each do |table|
   database << {:table_name=>table, :data=>CSV.new(ic.iconv(`mdb-export "#{workspace}#{accepted[(file_id.to_i-1)][:file]}" "#{table}"`), :headers => true).collect{|r| r.to_hash}}
end

database.each do |table|
  puts "\n\n\t> #{table[:table_name]}"
  puts table[:data][0]
end

Ripl.start