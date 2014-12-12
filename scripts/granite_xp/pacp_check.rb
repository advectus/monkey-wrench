require 'ripl'
require 'iconv'

# we have a granite xp mdb, are the observations pacp coded? 

abort "usage: ruby granite_xp_pacp_check.rb mdb_workspace" if ARGV.length < 1

mdb_workspace = "#{ARGV[0]}"

puts "Start"
ic = Iconv.new('UTF-8//IGNORE', 'UTF-8') #Invalid byte sequenece string conversion
pacp_coded_observations = {}
file = STDIN.gets.chomp

count = 0

mdbs = Dir["#{mdb_workspace}**/*.mdb"]

mdbs.each do |file|

    new_file = File.basename file
    puts new_file

    observation_codes = `mdb-export "#{file}" "OBSERVATION"`.split("\n").map{|o| o.split(",")[2]}
    puts observation_codes.size

    ic.iconv(`mdb-export "#{file}" "CODE"`).split("\n").each do |code_record|
    	code_record_id = code_record.split(",")[0].to_i
    	if code_record_id.is_a? Integer
    		if observation_codes.include? "#{code_record_id}"
    			abrev = code_record.split(",")[1]#.gsub('\"','')
    			pacp_coded_observations[abrev] = true
    		end
    	end
    end

end

Ripl.start