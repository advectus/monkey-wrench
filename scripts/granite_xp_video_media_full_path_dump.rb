require 'ripl'

# lets see all of the file names for all of the inspection videos in the provided mdbs

abort "usage: ruby granite_xp_video_media_full_path_dump.rb mdb_workspace media_workspace" if ARGV.length < 2

mdb_workspace = "#{ARGV[0]}"
media_workspace = "#{ARGV[1]}"

puts "Start"
file = STDIN.gets.chomp

count = 0
full_path = []
matched = []
media_types = ["mpg","mpeg","avi"]
mdbs = Dir["#{mdb_workspace}**/*.mdb"].collect{|file| {:id=>count+=1, :file=>file.gsub("#{mdb_workspace}","")}}
media = Dir["#{media_workspace}**/*.{mpg,mpeg,avi}"]

mdbs.each do |mdb|
    # files names from FULL_PATH in VIDEO_MEDIA table
	mdb[:video_media] = `mdb-export "#{mdb_workspace}#{mdb[:file]}" "VIDEO_MEDIA"`.split(",").reject{|d| not media_types.any? {|f| d.include? f }}.collect{|x| x.strip.gsub("\"","")} rescue []
    full_path += mdb[:video_media]
end

full_path = full_path.uniq
puts "Media files listed in mdbs\n\tTOTAL: #{full_path.count}"
puts "Media files on file system\n\tTOTAL: #{media.size}"

# lets see which of the records we found have media

full_path.each do |media_file|
    if media.include? media_file
        matched << media_file
    end
end

puts matched
puts "Inspection records that we have media for\n\tTOTAL: #{matched.count}"

Ripl.start