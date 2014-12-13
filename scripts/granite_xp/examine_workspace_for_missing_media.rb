require 'ripl'

# lets see all of the file names for all of the inspection videos in the provided mdbs

abort "usage: ruby examine_workspace_for_missing_media.rb workspace" if ARGV.length < 1

workspace = "#{ARGV[0]}"

puts "Start"
file = STDIN.gets.chomp

count = 0
all_media_per_mdb = []
matched = []
missing_media_report = []
media_types = ["mpg","mpeg","avi"]
mdbs = Dir["#{workspace}**/*.mdb"].collect{|file| {:id=>count+=1, :file=>file.gsub("#{workspace}","")}}
full_path_media = Dir["#{workspace}**/*.{mpg,mpeg,avi}"]
media = Dir["#{workspace}**/*.{mpg,mpeg,avi}"].collect{|m| m.split("/").last}

mdbs.each do |mdb|
  # files names from FULL_PATH in VIDEO_MEDIA table
  mdb[:video_media] = `mdb-export "#{workspace}#{mdb[:file]}" "VIDEO_MEDIA"`.split(",").reject{|d| not media_types.any? {|f| d.include? f }}.collect{|x| x.strip.gsub("\"","")} rescue []
  all_media_per_mdb += mdb[:video_media]
end
all_media_per_mdb = all_media_per_mdb.uniq

# out of which records do we have media for
all_media_per_mdb.each do |media_file|
  if media.include? media_file
    matched << media_file if not matched.include? media_file
  end
end

mdbs.each do |mdb|
  mdb[:video_media].each do |file|
    if not matched.include? file
      missing_media_report << {:mdb => mdb[:file], :media => file}
    end
  end
end

puts "\n----------------WHICH RECORDS DO WE NOT HAVE MEDIA FOR--------------------\n"
puts missing_media_report
puts "Media files listed in mdbs\n\tTOTAL: #{all_media_per_mdb.count}"
puts "Media files on file system\n\tTOTAL: #{media.size}"
puts "Inspection records that we do not have media for\n\tTOTAL: #{missing_media_report.count}"


Ripl.start