Drake
=====

AI and Game research

This game requires the use of the unstable Love2D build 0.9.X

Running the game
----------------

Ubuntu 13.04:

sudo apt-get install love-unstable

love-unstable /path/to/Drake/

Windows:

Download the nightly build from http://nightly.projecthawkthorne.com/

The easiest way to run the game is to drag the folder onto love.exe, or a shortcut to love.exe. Remember to drag the folder containing main.lua, and not main.lua itself.

NOTE: The nightly build has one API call difference than the Linux version

On Viewport line 48 and 59 change self.tilesetBatch.addg( to self.tilesetBatch.add(
