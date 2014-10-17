require 'csv'
require 'ripl'
require 'iconv'

# do you know this schema? are the observations PACP coded?

abort "usage: ruby granite_xp_schema_check.rb workspace publisher_repo" if ARGV.length < 2

workspace = "#{ARGV[0]}"
publisher = "#{ARGV[1]}"

GRANITE_XP_TABLES = [
    "ADJACENT_PIPE_INFO",
    "ARCGIS_IMPORT",
    "ARCGIS_NETWORK",
    "ASSET",
    "CODE",
    "CODES_GROUP",
    "CODE_CATEGORY",
    "CODE_SYSTEM",
    "CODE_SYSTEM_SCORING_INDEX",
    "DBHISTORY",
    "DB_VERSION_STAMP",
    "FIELD_DEFS",
    "HASH",
    "INSPECTION_RATING",
    "LATERAL",
    "LATERAL_INSPECTION",
    "LATERAL_OBSERVATION",
    "LATERAL_OBSERVATION__PHOTOS",
    "MAIN_INCLINATION_SURVEY",
    "MAIN_INSPECTION",
    "MAIN_INSPECTION__RATINGS",
    "MAIN_INSPECTION__SONAR_MEDIA",
    "MANHOLE",
    "MANHOLE__ASSETS",
    "MANHOLE__COVER_TYPES",
    "MANHOLE__SURFACE_TYPES",
    "MEDIA_CATALOG",
    "MH_INSPECTION",
    "MH_INSPECTION__COVER_CNDS",
    "MH_INSPECTION__FRAME_CNDS",
    "MH_INSPECTION__INSERT_CNDS",
    "MH_INSPECTION__PHOTOS",
    "MH_INSPECTION__RING_CNDS",
    "MH_INSPECTION__SEAL_CNDS",
    "MH_OBSERVATION",
    "MH_OBSERVATION__PHOTOS",
    "NOTE",
    "OBJECT_TYPES",
    "OBSERVATION",
    "OBSERVATION_RATING",
    "OBSERVATION__PHOTOS",
    "PHOTO",
    "PROJECT",
    "SAMPLES_FILE",
    "SEALING",
    "SEALING__PHOTOS",
    "SEAL_GROUT_INSP",
    "SETTING",
    "SONAR_MEDIA",
    "UNIT",
    "UNIT_CLASS",
    "UNIT_SYSTEM",
    "VIDEO_MEDIA"
].freeze

GRANITE_XP_DIFF_A = [
    "Errors",
    "MANHOLE__COVER_CNDS",
    "MANHOLE__FRAME_CNDS",
    "MANHOLE__INSERT_CNDS",
    "MANHOLE__RING_CNDS",
    "MANHOLE__SEAL_CNDS",
    "Paste"
].freeze

GRANITE_XP_TABLES_B = [
    "ASSET",
    "CODE",
    "INSPECTION_RATING",
    "MAIN_INSPECTION",
    "MAIN_INSPECTION__RATINGS",
    "MANHOLE",
    "OBSERVATION",
    "OBSERVATION__PHOTOS",
    "PHOTO",
    "PROJECT",
    "VIDEO_MEDIA"
].freeze

GRANITE_XP_TABLES_A = (GRANITE_XP_TABLES.dup << GRANITE_XP_DIFF_A).flatten.sort

puts "Start"
file = STDIN.gets.chomp

count = 0
ic = Iconv.new('UTF-8//IGNORE', 'UTF-8') #Invalid byte sequenece string conversion
accepted = Dir["#{workspace}**/*"].reject{|file| not file.include? ".mdb"}.collect{|file| {:id=>count+=1, :file=>file.gsub("#{workspace}","")}}

accepted.each do |mdb|

	mdb[:database], mdb[:schema] = [], []

	`mdb-tables "#{workspace}#{mdb[:file]}"`.split(" ").each do |table|
		puts table
		mdb[:schema] << table
		mdb[:database] << {:table_name=>table, :data=>CSV.new(ic.iconv(`mdb-export "#{workspace}#{mdb[:file]}" "#{table}"`), :headers => true).collect{|r| r.to_hash}}
	end

	mdb[:schema].sort!

	mdb[:schema_match] = (mdb[:schema]==GRANITE_XP_TABLES or mdb[:schema]==GRANITE_XP_TABLES_A or mdb[:schema]==GRANITE_XP_TABLES_B)

	if mdb[:schema_match]
		mdb[:observations] = ic.iconv(`mdb-export "#{workspace}#{mdb[:file]}" "CODE"`).split(",")[17]
	end

end

puts accepted
scoped = []

accepted.each do |mdb|
	scoped.push(
		{
			:file => mdb[:file],
			:schema_match => mdb[:schema_match],
			:code_schema => mdb[:observations]
		}
	)
end

Ripl.start