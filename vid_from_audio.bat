
REM Downscaling input image first allows us to encode faster 
tools\ffmpeg.exe -y -i "%~1\image.jpg" -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -update true -frames:v 1 "%~1\scaled.png"

if exist "%~1\single.mp3" (
	REM Audio is coming from a single file
	echo file '%~1\single.mp3' > "%~1\playlist.txt"
) else (
	REM Create a playlist of intro + 48 loops
	echo file '%~1\intro.mp3' > "%~1\playlist.txt"
	for /l %%x in (1, 1, 48) do (
	   echo file '%~1\loop.mp3' >> "%~1\playlist.txt"
	)
)

REM use ffmpeg to create one big wav
tools\ffmpeg.exe -f concat -safe 0 -i "%~1\playlist.txt" -c copy "%~1\audio.wav"

REM Now use ffmpeg to render final video. 
REM Raising CRF from 25 up to 50 will give smaller files
REM LOwering audio bitrate from 112k will give smaller files
tools\ffmpeg.exe -y -r 1 -loop 1 -i "%~1\scaled.png" -i "%~1\audio.wav" ^
   -c:v libx264 -tune stillimage -pix_fmt yuv420p -crf 29  ^
   -bufsize 10M -maxrate 22k ^
   -c:a libopus -b:a 96k -shortest ^
   -movflags +faststart "%~1\video.mp4"

REM Cleanup intermediate files
del /Q "%~1\scaled.png" "%~1\audio.wav" "%~1\playlist.txt"

echo "Your video is ready!"
pause
explorer %1
