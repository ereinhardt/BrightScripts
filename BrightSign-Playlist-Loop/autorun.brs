' PLAYLIST LOOP SCRIPT

' This script plays a list of video/audio files one after another in a loop on one BrightSign player.
' Based on Zach Poff, modified by Erik Anton Reinhardt.

' Usage
' Place this script at the root of a blank microSD card.
' Typically this file would be named to autorun.brs so it starts automatically.
' Put your video or audio files (MOV, MP4, MPG, VOB, MP3, WAV, OGG, TS) at the root of a blank microSD card as well.
' Make adjustments to the variables below.

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Variables

videoFiles = "auto"
'    (use "auto" to automatically play ALL playable files on the SD card in alphabetical order,
'     otherwise insert a list of filenames "in quotes", separated by commas, inside square brackets.
'     The files are played one after another in the given order and the playlist loops forever, e.g.:
'     videoFiles = ["intro.mp4", "film.mov", "outro.mp4"]
'     A single file works as well: videoFiles = ["film.mp4"])

VideoMode = "auto"
'    (use "auto" to automatically negotiate the display resolution, or insert from list below "in quotes")

ScaleMode = 1
'	 (How should the video be scaled if it doesn't match the screen? ... Insert a number from list below, NOT in quotes)
'    0 = "Scale To Fit"				Scales the video to fill the window in both dimensions. The aspect ratio of the video is ignored, so the video may be stretched/squashed.
'    1 = "Letterboxed And Centered"	(recommended) Scales the video to fill the window in the longest dimension, adding letterbox/pillarbox if required to maintain video aspect ratio.
'    2 = "Fill Screen And Centered"	Scales the video to fill the window in the shortest dimension. The aspect ratio is maintained, so the long dimension may be cropped.
'    3 = "Centered"					Centers the window with no scaling.

audioVolume = 15
'    (the volume of the audio output, in percent... 
'     These players have LOUD outputs so try 10-20 for sane headphone levels!)


' VIDEO MODES
' -----------
' The list below shows resolutions supported by MOST players. For the exact resolutions that YOUR player supports, go here:
' https://brightsign.zendesk.com/hc/en-us/articles/218065627-Supported-video-output-resolutions

' Older players with VGA ports can display NTSC/PAL component/S-Video/composite(CVBS) via an adapter: 
' http://support.brightsign.biz/entries/22929977-Can-I-use-component-and-composite-video-with-BrightSign-players-
'    
'    via HDMI / Component:
'    ---------------------
'    ntsc-component
'    pal-component 
'    ntsc-m 
'    ntsc-m-jpn 
'    pal-i 
'    pal-bg 
'    pal-n 
'    pal-nc 
'    pal-m 
'    720x576x50p
'    720x480x59.94p
'    720x480x60p
'    1280x720x50p
'    1280x720x59.94p
'    1280x720x60p
'    1920x1080x50i
'    1920x1080x59.94i
'    1920x1080x60i
'    1920x1080x24p   (not backwards compatible)
'    1920x1080x29.97p
'    1920x1080x30p   (not backwards compatible)
'    1920x1080x50p
'    1920x1080x59.94p
'    1920x1080x60p

'    via HDMI / VGA:
'    ---------------
'    640x480x60p 
'    800x600x60p 
'    800x600x75p 
'    1024x768x60p 
'    1024x768x75p 
'    1280x768x60p 
'    1280x800x60p 
'    1360x768x60p 

'    4k output via HDMI (upscaled from HD content)
'    for HD222, HD1022, XD232, XD1032, XD1132 players
'    ---------------
'    3840x2160x24p
'    3840x2160x25p
'    3840x2160x29.97p
'    3840x2160x30p

' ----------------------------------------------------
' DON'T edit anything below this line.
' (unless you know exactly what you're doing)
' ----------------------------------------------------

'---- Find all playable files on SD card ----
foundFiles = []
list=ListDir("/")
for each file in list
	if ucase(right(file,3)) = "MOV" or ucase(right(file,3)) = "MP4" or ucase(right(file,3)) = "MPG" or ucase(right(file,3)) = "VOB" or ucase(right(file,3)) = "MP3" or ucase(right(file,3)) = "WAV" or ucase(right(file,3)) = "OGG" or ucase(right(file,2)) = "TS" then
		if not left(file,1) = "." then 'reject dotfiles!
			foundFiles.Push(file)
		endif
	endif
next

'---- Sort found files alphabetically (insertion sort) ----
for i = 1 to foundFiles.Count() - 1
	current = foundFiles[i]
	j = i - 1
	while j >= 0
		if ucase(foundFiles[j]) <= ucase(current) then exit while
		foundFiles[j+1] = foundFiles[j]
		j = j - 1
	end while
	foundFiles[j+1] = current
next

'---- Build playlist ----
if type(videoFiles) = "roArray" then
	playlist = videoFiles
else if ucase(videoFiles) = "AUTO" then
	playlist = foundFiles
else
	playlist = [videoFiles] 'single filename given as plain string
endif

if playlist.Count() = 0 then
	print "No playable files found - nothing to play"
	while true
		sleep(1000)
	end while
endif

for each entry in playlist
	print "Playlist: "; entry
next

currentIndex = 0

'---- Setup video player ----
v = CreateObject("roVideoPlayer")

p = CreateObject("roMessagePort")
v.SetPort(p)
v.SetViewMode(ScaleMode)
v.SetVolume(audioVolume)

mode=CreateObject("roVideoMode")
mode.SetMode(VideoMode)


start:
	videoFile = playlist[currentIndex]
	print "start: "; videoFile
	if v <> invalid then
		v.Stop()
		sleep(50)
		ok = v.PlayFile(videoFile)
	else
		' Recreate player if it was destroyed
		v = CreateObject("roVideoPlayer")
		v.SetPort(p)
		v.SetViewMode(ScaleMode)
		v.SetVolume(audioVolume)
		ok = v.PlayFile(videoFile)
	endif

	if not ok then
		' File missing or not playable - skip to next entry
		print "Could not play "; videoFile; " - skipping"
		currentIndex = (currentIndex + 1) mod playlist.Count()
		sleep(1000)
		goto start
	endif


listen:
	msg = wait(10,p)
	
	if type(msg) = "roVideoEvent" and msg.GetInt() = 8 then
		print "Video ended - forcing black screen"
		v.Stop()
		v = invalid
		sleep(100)
		' Recreate video player for black screen
		v = CreateObject("roVideoPlayer")
		v.SetPort(p)
		v.SetViewMode(ScaleMode)
		v.SetVolume(audioVolume)
		print "Player reset - black screen active"
	    sleep(900)
		' Advance to next file, wrap around at end of playlist
		currentIndex = (currentIndex + 1) mod playlist.Count()
		goto start
	endif

	goto listen
