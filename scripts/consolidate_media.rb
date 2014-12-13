require 'ripl'

# cp all of the media scattered in child directories into 1 staging directory

abort "usage: ruby consolidate_media.rb media_workspace" if ARGV.length < 1

media_workspace = "#{ARGV[0]}"

puts "Start"
file = STDIN.gets.chomp

count = 0

media = Dir["#{media_workspace}/**/*.{mpg,mpeg,avi}"]
stage = `mkdir "#{media_workspace}/Stage"`

puts media.size

media.each do |file|

    new_file = File.basename file
    extn = File.extname file
    name = File.basename new_file, extn

    origin = file.gsub(/ /,'\ ').gsub('(','\(').gsub(')','\)').gsub('&','\&')
    puts origin
    dest = "#{media_workspace}/Stage/#{name}.mpg".gsub(/ /,'\ ').gsub('(','\(').gsub(')','\)').gsub('&','\&')
    puts dest
    system("cp #{origin} #{dest}")

    if File.zero?("#{media_workspace}/Stage/#{name}.mpg")
    	puts "#{dest} is 0 bytes"
    	system("rm -f #{dest}")
    end

end

Ripl.start