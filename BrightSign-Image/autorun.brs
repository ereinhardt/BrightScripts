' IMAGE SCRIPT

' This script displays a single image or a slideshow of images on one BrightSign player.
' Based on Zach Poff, modified by Erik Anton Reinhardt.

' Usage
' Place this script at the root of a blank microSD card.
' Typically this file would be named to autorun.brs so it starts automatically.
' Put one or more image files (JPG, JPEG, PNG, BMP) at the root of a blank microSD card as well.
' Make adjustments to the variables below.

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Variables

ImageFile = "auto"
'    (use "auto" to run a slideshow of all images on the SD card (sorted alphabetically),
'     otherwise insert the filename of a single image "in quotes" to display only that image)

DiaSpeed = 5000
'    (slideshow: display duration of each image in milliseconds (ms), NOT in quotes ... only used when ImageFile = "auto")

VideoMode = "auto"
'    (use "auto" to automatically negotiate the display resolution, or insert from list below "in quotes")

ScaleMode = 1
'	 (How should the image be scaled if it doesn't match the screen? ... Insert a number from list below, NOT in quotes)
'    0 = "Scale To Fit"				Scales the image to fill the screen in both dimensions. The aspect ratio of the image is ignored, so the image may be stretched/squashed.
'    1 = "Letterboxed And Centered"	(recommended) Scales the image to fill the screen in the longest dimension, adding letterbox/pillarbox if required to maintain image aspect ratio.
'    2 = "Fill Screen And Centered"	Scales the image to fill the screen in the shortest dimension. The aspect ratio is maintained, so the long dimension may be cropped.
'    3 = "Centered"					Centers the image with no scaling.


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

'---- Find all displayable images on SD card ----
images = CreateObject("roArray", 10, true)
for each file in ListDir("/")
	if not left(file,1) = "." then 'reject dotfiles!
		ext = ""
		for i = len(file) to 1 step -1
			if mid(file, i, 1) = "." then
				ext = ucase(mid(file, i + 1))
				exit for
			endif
		next
		if ext = "JPG" or ext = "JPEG" or ext = "PNG" or ext = "BMP" then
			images.Push(file)
		endif
	endif
next

'---- Sort images alphabetically (case-insensitive) ----
for i = 1 to images.Count() - 1
	key = images[i]
	j = i - 1
	while j >= 0
		if lcase(images[j]) <= lcase(key) then exit while
		images[j + 1] = images[j]
		j = j - 1
	end while
	images[j + 1] = key
next

slideshow = (ImageFile = "auto")
if not slideshow then
	images.Clear()
	images.Push(ImageFile)
endif

'---- Map ScaleMode to roImagePlayer modes ----
' roImagePlayer: 0 = Centered, 1 = Letterboxed, 2 = Fill and crop, 3 = Stretch
scaleMap = [3, 1, 2, 0]
imageMode = 1
if ScaleMode >= 0 and ScaleMode <= 3 then imageMode = scaleMap[ScaleMode]

if DiaSpeed < 100 then DiaSpeed = 100

'---- Setup display ----
mode = CreateObject("roVideoMode")
mode.SetMode(VideoMode)

p = CreateObject("roMessagePort")
img = CreateObject("roImagePlayer")
img.SetDefaultMode(imageMode)
img.SetDefaultTransition(0)

if images.Count() = 0 then
	print "No images found - black screen"
	while true
		wait(0, p)
	end while
endif

'---- Single image (or only one image found) ----
if not slideshow or images.Count() = 1 then
	print "Displaying "; images[0]
	img.DisplayFile(images[0])
	while true
		wait(0, p)
	end while
endif

'---- Slideshow ----
index = 0
img.DisplayFile(images[index])
while true
	nextIndex = (index + 1) mod images.Count()
	img.PreloadFile(images[nextIndex])
	wait(DiaSpeed, p)
	img.DisplayPreload()
	index = nextIndex
end while
