require 'ripl'

# lets see all of the file names for all of the inspection videos in the provided mdbs

abort "usage: ruby granite_xp_video_media_full_path_dump.rb workspace" if ARGV.length < 1

workspace = "#{ARGV[0]}"

puts "Start"
file = STDIN.gets.chomp

count = 0
full_path = []
media_types = ["mpg","mpeg","avi"]
accepted = Dir["#{workspace}**/*"].reject{|file| not file.include? ".mdb"}.collect{|file| {:id=>count+=1, :file=>file.gsub("#{workspace}","")}}

accepted.each do |mdb|

    # files names from FULL_PATH in VIDEO_MEDIA table
	mdb[:video_media] = `mdb-export "#{workspace}#{mdb[:file]}" "VIDEO_MEDIA"`.split(",").reject{|d| not media_types.any? {|f| d.include? f }}.collect{|x| x.strip.gsub("\"","")} rescue []
    full_path += mdb[:video_media]

end

full_path = full_path.uniq
puts full_path.count

Ripl.start