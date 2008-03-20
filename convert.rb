def check_usage
  unless ARGV.length == 2
    puts "Usage: convert.rb <infile> <outfile>"
    exit
  end
end

def transcode_video(infile, outfile)
  puts "transcoding " + infile + " to " + outfile
  system "ffmpeg -y -i " + infile + " -t 00:01:00 -threads 4 -s 640x480 -aspect 640:480 -r 29.97 -vcodec libx264 -g 150 -qmin 25 -qmax 51 -b 1000k -maxrate 1450k -level 30 -loop 1 -sc_threshold 40 -refs 2 -keyint_min 40 -partp4x4 1 -rc_eq 'blurCplx^(1-qComp)' -deinterlace -croptop 5 -cropbottom 5 -cropleft 5 -cropright 5 -async 50 -acodec libfaac -ar 48000 -ac 2 -ab 128k -f mp4 " + outfile
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