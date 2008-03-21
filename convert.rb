#ToDo:
#add a check to getpath to return "" if nil

require 'rubygems'
require 'active_record'
require 'composite_primary_keys'
require 'yaml'

DEBUG = true

class Recorded < ActiveRecord::Base
  set_table_name "recorded"
  set_primary_keys :chanid, :starttime
end

def check_usage
  #check for the proper inputs
  unless ARGV.length == 2
    #if not, display the usage instruction
    puts "Usage: convert.rb <infile> <outfile>"
    exit
  end
end

def getpath(file)
  #I think this is probably a stupid way to do this...
  file.split(file.split('/').pop)[0]
end

def getfile(file)
  file.split('/').pop
end

def getmeta(file)
  Recorded.find_by_basename(file)
end

def transcode_video(infile, outfile)
  #ffmpeg command
  ffmpeg_cmd = "nice -n " + CONFIG['nice_level'] + " " + CONFIG['ffmpeg'] + " -i " + infile + " " + CONFIG['ffmpeg_options'] + " " + getpath(outfile) + "ss_" + getfile(outfile)
  #report
  puts "transcoding " + infile + " to " + getpath(outfile) + "ss_" + getfile(outfile)
  puts ffmpeg_cmd if DEBUG
  #execute ffmpeg_cmd
  system ffmpeg_cmd
end

def quickstart_video(outfile)
  #qt-faststart command
  qtfaststart_cmd = CONFIG['qtfaststart'] + " " + getpath(outfile) + "ss_" + getfile(outfile) + " " + getpath(outfile) + "qs_" + getfile(outfile)
  #report
  puts "modifying " + getpath(outfile) + "ss_" + getfile(outfile) + " for streaming, saving as " + getpath(outfile) + "qs_" + getfile(outfile)
  puts qtfaststart_cmd if DEBUG
  #execute qtfaststart_cmd
  system qtfaststart_cmd
end

def add_metadata(infile, outfile)
  #get metadata
  metadata = getmeta(getfile(infile))
  p metadata.attributes if DEBUG
  #AtomicParsley command
  atomicparsley_cmd = CONFIG['atomicparsley'] + " " + getpath(outfile) + "qs_" + getfile(outfile) + " --output " + outfile + " --genre \"" + metadata.category + "\" --stik \"TV Show\" --TVNetwork \"\" --TVShowName \"" + metadata.title + "\" --title \"" + metadata.subtitle + "\" --description \"" + metadata.description + "\""
  #report
  puts "adding metadata to " + getpath(outfile) + "qs_" + getfile(outfile) + ", saving as " + outfile
  puts atomicparsley_cmd if DEBUG
  #execute atomicparsley_cmd
  system atomicparsley_cmd
end

def upload_video(outfile)
  #scp command
  scp_command = CONFIG['scp'] + " " + outfile + " " + CONFIG['upload_user'] + '@' + CONFIG['upload_host'] + ":" + CONFIG['upload_path']
  #report
  #puts "uploading"
end

if $0 == __FILE__
  check_usage
  
  CONFIG        = YAML.load_file(getpath(__FILE__) + "config.yml")
  infile        = ARGV[0]
  outfile       = ARGV[1]
  
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.colorize_logging = false

  ActiveRecord::Base.establish_connection(
      :adapter  => "mysql",
      :host     => CONFIG['host'],
      :database => CONFIG['database'],
      :username => CONFIG['username'],
      :password => CONFIG['password']
  )
  
  transcode_video(infile, outfile)
  quickstart_video(outfile)
  add_metadata(infile, outfile)
end

=begin
Stuff to work with...

ffmpeg command, broken down into options:
ffmpeg
-y                                  write over if file exists
-i in.mpg                           infile
-threads 4                          number of threads to kill your processor
-s 640x480                          size of output file
-aspect 640:480                     aspect ratio
-r 29.97                            framerate
-vcodec h264                        video codec (changes by build of ffmpeg: h264, x264, libx264)
-g 150                              gop (group of pictures) size ??
-qmin 25                            minimum video quantizer scale (VBR) ??
-qmax 51                            maximum video quantizer scale (VBR) ??
-b 1000k                            video bitrate (larger = better quality = bigger file = more bandwith needed)
-maxrate 1450k                      maximum video bitrate
-level 30                           ??
-loop 1                             ??
-sc_threshold 40                    ??
-partp4x4 1                         part is video partitioning, not sure what this is ??
-rc_eq `blurCplx^(1-qComp)`         ??
-deinterlace                        deinterlace video (can I detect if input is interlaced?)
-refs 2                             ?? 
-keyint_min 40                      ??
-async 50                           audio sync goodness
-acodec libfaac                     audio codec (changes by build of ffmpeg: acc, facc, libfacc)
-ar 48000                           audio frequency
-ac 2                               audio channels
-ab 128k                            audio bitrate
-f mp4                              force mp4 output, sometimes ffmpeg doesn't detect it based on the filename
out.mp4                             outfile

AtomicParsley:
AtomicParsley infile 
--genre "Travel" 
--stik "TV Show" 
--TVNetwork TRAV 
--TVShowName "Michael Palin's New Europe" 
--title "From the Rila Mountains to Cappodoccia" 
--description "Michael crosses into Bulgaria where he treks up to the Rila Mountains to join the summer solstice celebrations."

=end