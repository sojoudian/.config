brew install ffmpeg
ffmpeg -i "input.mp4" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k -movflags +faststart "output.mp4"
ffmpeg -i "input.mp4" -ss 00:00:05 -to 00:03:06 -c:v copy -c:a copy "output.mp4" 
