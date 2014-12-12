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
matched_report = []
media_types = ["mpg","mpeg","avi"]
mdbs = Dir["#{mdb_workspace}**/*.mdb"].collect{|file| {:id=>count+=1, :file=>file.gsub("#{mdb_workspace}","")}}
full_path_media = Dir["#{media_workspace}**/*.{mpg,mpeg,avi}"]
media = Dir["#{media_workspace}**/*.{mpg,mpeg,avi}"].collect{|m| m.split("/").last}

mdbs.each do |mdb|
    # files names from FULL_PATH in VIDEO_MEDIA table
	mdb[:video_media] = `mdb-export "#{mdb_workspace}#{mdb[:file]}" "VIDEO_MEDIA"`.split(",").reject{|d| not media_types.any? {|f| d.include? f }}.collect{|x| x.strip.gsub("\"","")} rescue []
    full_path += mdb[:video_media]
end
full_path = full_path.uniq

# out of which records do we have media for
full_path.each do |media_file|
    if media.include? media_file
        if not matched.include? media_file
            matched << media_file
        end
    end
end
media.each do |media_file|
    if full_path.include? media_file
        if not matched.include? media_file
            matched << media_file
        end
    end
end
mdbs.each do |mdb|
    mdb[:video_media].each do |file|
        if matched.include? file
            # determine the location of a file
            full_path_media.each{|x|
                if x.include? file
                    matched_report << {:file => mdb[:file], :local_file => x.gsub("#{media_workspace}",""), :mdb_file => file}
                end
            }
        end
    end
end

# we ran the stats and built the dictionary, now lets rename the media so that it matches the inspection record
# full_path_media.each do |file|

#     path = "/Users/edmricha/Desktop/TMP_MDB/V/Processed/"
#     new_file = File.basename file

#     #check to see if this media is in any of the mdbs
#     found = false
#     mdbs.each do |mdb|
#         if mdb[:video_media].include? new_file
#             found = true
#         end
#     end

#     puts new_file, found

#     # if the media file on the file system was not found in any of the mdb inspection records
#     # lets try to rename the file on the file system so that it matches that of its closest match in the inspection records
#     if not found

#         #lets first try to ensure all the file on the file system are .mpg, not .mpeg
#         extn = File.extname  file        # => ".mp4"
#         name = File.basename file, extn        # => "xyz"
#         #path = File.dirname  file        # => "/path/to"
#         puts file.gsub(" ","\ ")
#         puts extn
#         puts name
#         #puts path
#         #puts "cp \"#{file}"\ "#{path}/#{name}.mpg"
#         #{}`cp \""#{file}"\" \""#{path}#{name}".mpg\"`

#         puts "#{path}/#{name}.mpg"
#         File.open("#{path}#{name}.mpg", 'w') { |file|
#             file.write( File.open(file).read() )
#         }
#     end

# end


# we now need to remove duplicates from the matches report
good_file_list = []
matched_report.each do |item|
    good_file_list.push(item[:file])
end

blob = {}
good_file_list.uniq.each do |file|
    matched_report.each do |item|
        if item[:file]==file
            blob[file] ||= []
            blob[file].push(item[:local_file])
        end
    end
end



puts "\n----------------MEDIA FILES LISTED IN MDB--------------------\n"
#puts full_path
puts "\n----------------MEDIA UPLOADED TO DRIVE--------------------\n"
#puts media
puts "\n----------------WHICH RECORDS DO WE HAVE MEDIA FOR--------------------\n"
puts matched_report
puts "\n----------------LIST OF ALL THE MDBS WE SHOULD CONSIDER--------------------\n"
puts good_file_list.uniq
puts "\n----------------WHATS IN EACH OF THOSE MDBS--------------------\n"
puts blob
puts "Media files listed in mdbs\n\tTOTAL: #{full_path.count}"
puts "Media files on file system\n\tTOTAL: #{media.size}"
puts "Inspection records that we have media for\n\tTOTAL: #{matched.count}"
if matched_report.count!=matched.count
    puts "Error"
end

Ripl.start