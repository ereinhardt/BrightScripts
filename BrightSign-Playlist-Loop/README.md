# BrightSign-Playlist-Loop (v.1.0-10-2026)

A simple BrightSign script that plays a list of video or audio files one after another in a loop on one player – no network or sync required.

by Erik Anton Reinhardt (Based on Zach Poff).<br>
[MIT License]

---

**Usage**: <br>

- Copy `autorun.brs` to the root of the BrightSign microSD card.
- Place your video or audio files (MOV, MP4, MPG, VOB, MP3, WAV, OGG, TS) in the same location.
- Set `videoFiles` in the script:
  - `videoFiles = "auto"` plays all playable files on the card in alphabetical order.
  - `videoFiles = ["intro.mp4", "film.mov", "outro.mp4"]` plays exactly these files in the given order.
- After the last file the playlist starts over from the beginning. Files that are missing or not playable are skipped.
- Configure the output settings (resolution, scale mode, volume) as described in the script.
