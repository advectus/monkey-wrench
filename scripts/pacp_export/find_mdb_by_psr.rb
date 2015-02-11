require 'ripl'

# here is a psr, which mdb out of the several did it come from?

abort "usage: ruby find_mdb_by_psr.rb mdb_workspace query" if ARGV.length < 2

mdb_workspace = "#{ARGV[0]}"
query = "#{ARGV[1]}"

puts "Start"
file = STDIN.gets.chomp

count = 0
total_inspections = 0
matching_mdbs = []
mdbs = Dir["#{mdb_workspace}**/*.mdb"].collect{|file| {:id=>count+=1, :file=>file.gsub("#{mdb_workspace}","")}}

# add observation media array to mdb hash
mdbs.each do |mdb|
    mdb[:inspection_data] = `mdb-export "#{mdb_workspace}#{mdb[:file]}" "Inspections"`.split(",").reject{|d| d==""}.collect{|d| d}
    mdb[:discovered] = false
    # loop over all inspection_data
    mdb[:inspection_data].each do |data|
        if data.to_s.gsub('"','') == query       
            mdb[:discovered] = true
            matching_mdbs << mdb[:file] if not matching_mdbs.include? mdb[:file]
        end
    end
end


puts "\n----------------MDB PARSE--------------------\n"
puts "Total number of mdbs\n\tTOTAL: #{mdbs.count}"
puts "Number of mdbs that have inspection data containing the query\n\tTOTAL: #{matching_mdbs.count}"
puts matching_mdbs


Ripl.start