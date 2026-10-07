# BrightSign-Image (v.1.0-10-2026)

A simple BrightSign script that displays a single image or a slideshow of images on one player – no network or sync required.

by Erik Anton Reinhardt (Based on Zach Poff).<br>
[MIT License]

---

**Usage**: <br>

- Copy `autorun.brs` to the root of the BrightSign microSD card.
- Place one or more image files (JPG, JPEG, PNG, BMP) in the same location.
- `ImageFile = "auto"`: all images are shown as a slideshow (alphabetical order), each for `DiaSpeed` milliseconds.
- `ImageFile = "myimage.png"`: only this single image is displayed.
- Configure the output settings (resolution, scale mode, slideshow speed) as described in the script.
