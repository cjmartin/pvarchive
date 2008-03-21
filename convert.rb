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
  puts "modifying for streaming " + getpath(outfile) + "ss_" + getfile(outfile) + " to " + getpath(outfile) + "qs_" + getfile(outfile)
  puts qtfaststart_cmd if DEBUG
  #execute qtfaststart_cmd
  system qtfaststart_cmd
end

if $0 == __FILE__
  check_usage
  CONFIG        = YAML.load_file("config.yml")
  infile        = ARGV[0]
  outfile       = ARGV[1]
  transcode_video(infile, outfile)
  quickstart_video(outfile)
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
=end