DEBUG = true

def check_usage
  #check for the proper inputs
  unless ARGV.length == 2
    #if not, display the usage instruction
    puts "Usage: convert.rb <infile> <outfile>"
    exit
  end
end

def transcode_video(infile, outfile)
  #settings - put these in a config.yml file when you figure out how
  nice_level = "19"
  ffmpeg = "/opt/local/bin/ffmpeg"
  ffmpeg_options = "-y -t 00:01:00 -threads 4 -croptop 6 -cropbottom 6 -cropleft 6 -cropright 6 -s 640x480 -aspect 640:480 -r 29.97 -vcodec libx264 -g 150 -qmin 25 -qmax 51 -b 1000k -maxrate 1450k -level 30 -loop 1 -sc_threshold 40 -refs 2 -keyint_min 40 -partp4x4 1 -rc_eq 'blurCplx^(1-qComp)' -deinterlace -async 50 -acodec libfaac -ar 48000 -ac 2 -ab 128k -f mp4"
  #ffmpeg command
  ffmpeg_cmd = "nice -n " + nice_level + " " + ffmpeg + " -i " + infile + " " + ffmpeg_options + " ss_" + outfile
  #report
  puts "transcoding " + infile + " to " + outfile
  puts ffmpeg_cmd if DEBUG
  #execute ffmpeg_cmd
  system ffmpeg_cmd
end

def quickstart_video(outfile)
  #settings - put these in a config.yml file when you figure out how
  qtfaststart = "/Users/cjmartin/bin/qt-faststart"
  #qt-faststart command
  qtfastatart_cmd = qtfaststart + "ss_" + outfile + "qs_" + outfile
  #execute qtfaststart_cmd
  system qtfaststart_cmd
end

if $0 == __FILE__
  check_usage
  infile  = ARGV[0]
  outfile = ARGV[1]
  transcode_video(infile, outfile)
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