require 'ripl'

# so do we have all of the observation photos?

abort "usage: ruby granite_xp_match_observation_photos.rb mdb_workspace media_workspace" if ARGV.length < 2

mdb_workspace = "#{ARGV[0]}"
media_workspace = "#{ARGV[1]}"

puts "Start"
file = STDIN.gets.chomp

count = 0
total_observation_photos = 0
found_media = []
not_found_media = []
media_types = ["jpg","jpeg","gif"]
mdbs = Dir["#{mdb_workspace}**/*.mdb"].collect{|file| {:id=>count+=1, :file=>file.gsub("#{mdb_workspace}","")}}
media = Dir["#{media_workspace}**/*.{jpg,jpeg,gif}"].collect{|m| m.split("/").last}

# add observation media array to mdb hash
mdbs.each do |mdb|
	mdb[:obersation_media] = `mdb-export "#{mdb_workspace}#{mdb[:file]}" "PHOTO"`.split(",").reject{|d| not media_types.any? {|f| d.include? f }}.collect{|x| x.strip.gsub("\"","")} rescue []
    total_observation_photos += mdb[:obersation_media].size

    # see if all media in the mdb hash is present on the file system
    mdb[:obersation_media].each do |file|

        if media.include? file
            found_media << file
        else
            not_found_media << file
        end

    end
end

puts "\n----------------PHOTOS WE DISCOVERED IN THE MDB --------------------\n"
puts media
puts "\n----------------TOTAL OBSERVATION PHOTOS--------------------\n"
puts "Observation Photos listed in database\n\tTOTAL: #{total_observation_photos}"
puts "Observation Photos not found on file system\n\tTOTAL: #{not_found_media.size}"
puts "Observation Photos found on file system\n\tTOTAL: #{found_media.size}"


Ripl.start