' WEBSITE SCRIPT

' This script displays a website on a BrightSign player.
' by Erik Anton Reinhardt.

' Usage
' Place this script at the root of a blank microSD card.
' Rename this file to autorun.brs so it starts automatically.
' Make adjustments to the variables below.

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Variables

websiteURL = "https://www.ereinhardt.org/"
'    (Enter the URL of the website you want to display "in quotes")

VideoMode = "auto"
'    (use "auto" to automatically negotiate the display resolution, or insert from list below "in quotes")

ScaleMode = 1
'    (How should the content be scaled if it doesn't match the screen? ... Insert a number from list below, NOT in quotes)
'    0 = "Scale To Fit"               Scales to fill the window in both dimensions.
'    1 = "Letterboxed And Centered"   (recommended) Scales to fill the window in the longest dimension.
'    2 = "Fill Screen And Centered"   Scales to fill the window in the shortest dimension.
'    3 = "Centered"                   Centers the window with no scaling.

audioVolume = 15
'    (the volume of the audio output, in percent)

' *** Scroll down to the "Setting Manual IP address" section if you
'     want to choose a different IP range.


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

'---- Setting DHCP (automatic IP from router) ---
nc = CreateObject("roNetworkConfiguration", 0)
nc.SetDHCP()
nc.Apply()

'---- Set Video Mode ---
mode = CreateObject("roVideoMode")
mode.SetMode(VideoMode)

'---- Get screen resolution for HTML widget ---
screenWidth = mode.GetResX()
screenHeight = mode.GetResY()

'---- Calculate letterbox rectangle to maintain aspect ratio ---
' Parse the video mode to get content dimensions
' If "auto", use the actual screen resolution (no letterboxing needed)
if VideoMode = "auto" then
    videoModeWidth = screenWidth
    videoModeHeight = screenHeight
else
    ' Handle special video mode names that don't contain resolution numbers
    ' NTSC modes: 720x480 (4:3)
    ' PAL modes: 720x576 (4:3)
    lowerMode = lcase(VideoMode)
    if instr(1, lowerMode, "ntsc") > 0 then
        videoModeWidth = 720
        videoModeHeight = 480
    else if instr(1, lowerMode, "pal") > 0 then
        videoModeWidth = 720
        videoModeHeight = 576
    else
        ' Extract dimensions from VideoMode string (e.g. "1920x1080x60p")
        videoModeWidth = screenWidth
        videoModeHeight = screenHeight
        regex = CreateObject("roRegex", "x", "i")
        parts = regex.Split(VideoMode)
        if parts.Count() >= 2 then
            parsedWidth = val(parts[0])
            parsedHeight = val(parts[1])
            if parsedWidth > 0 and parsedHeight > 0 then
                videoModeWidth = parsedWidth
                videoModeHeight = parsedHeight
            end if
        end if
    end if
end if

' Calculate aspect ratios
contentAspect = videoModeWidth / videoModeHeight
screenAspect = screenWidth / screenHeight

' Calculate letterboxed rectangle
if ScaleMode = 1 then
    ' Letterboxed and Centered
    if contentAspect < screenAspect then
        ' Content is narrower than screen - add pillarbox (bars on sides)
        newWidth = int(screenHeight * contentAspect)
        newHeight = screenHeight
        offsetX = int((screenWidth - newWidth) / 2)
        offsetY = 0
    else
        ' Content is wider than screen - add letterbox (bars on top/bottom)
        newWidth = screenWidth
        newHeight = int(screenWidth / contentAspect)
        offsetX = 0
        offsetY = int((screenHeight - newHeight) / 2)
    end if
    rect = CreateObject("roRectangle", offsetX, offsetY, newWidth, newHeight)
else
    ' For other scale modes, use full screen
    rect = CreateObject("roRectangle", 0, 0, screenWidth, screenHeight)
end if

'---- Create HTML Widget to display website ---
htmlWidget = CreateObject("roHtmlWidget", rect)

'---- Configure HTML Widget ---
htmlWidget.SetUrl(websiteURL)

'---- Create Message Port for events ---
p = CreateObject("roMessagePort")
htmlWidget.SetPort(p)

'---- Wait for network connection before loading website ---
print "Waiting for network connection..."
sleep(5000)

'---- Show the website ---
htmlWidget.Show()

print "Website loaded: " + websiteURL

'---- Main loop to keep the script running ---
listen:
    msg = wait(0, p)
    goto listen
