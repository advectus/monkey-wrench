require 'ripl'

# lets match the 

abort "usage: ruby granite_xp_match_media_to_the_media_path_inspection_record.rb media_workspace" if ARGV.length < 1

media_workspace = "#{ARGV[0]}"

puts "Start"
file = STDIN.gets.chomp

count = 0

media = Dir["#{media_workspace}**/*.{mpg,mpeg,avi}"]

media.each do |file|

    path = "/Users/edmricha/Desktop/TMP_MDB/V/Processed/"
    new_file = File.basename file
    puts new_file

    #`cp "#{file}" "#{new_file}"`

end

Ripl.start