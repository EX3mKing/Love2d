# Love2d
#### Video Demo: https://youtu.be/RPlJs-yJZSA
#### Description

It iIt is a 2d survival high-score chaser made in Lua with the LÖVE framework and the anim8 library.
You play as a white-haired samurai fighting a never-ending hoard of enemies. The only tool at your disposal
is your trusty sword. Weave through the hoard and survive for as long as you can. The enemy spawn rate amps up the more enemies you kill.

itch.io: https://bornab.itch.io/cs50 


#### Documentation
.git, .gitignore and .gitatributes are files used for source control (git).

folders: audio, libraries and sprites all contain stuff their names suggest.

conf.lua and main.lua are script files that Love2d reads and runs the game based on. \
conf.lua contains information about the initial state of the Love2d window. \
main.lua contains game logic. Functions inside are commented on.


#### Story
For cs50 final project, I have decided to make a game. But how and what sort? Inspired by Vampire Survivors, I ended up wanting to make a
simple survival high-score chaser. The next question was which language and what framework?
At first, I wanted to make it in Python with Pygame or in C++ with Raylib or SDL2. In the end, I decided to go with Lua and LÖVE.

My initial game idea was much bigger than what I ended up with. The original idea was that the player had two weapons, a gun and a sword.
Two abilities for each, one normal, one special. The player would have one resource: health. Each time player used a special ability or if he got
hit by an enemy he would lose health. If the player killed an enemy with the sword player would regain it.
After working for a while I decided against it. It would take too long. Not only to implement all of those abilities but to also animate them.
I needed to shorten the project so that I could finish it before the end of the summer break. After the break, I wouldn't have any time for
it. Shortened up idea, while bare-bones, allowed me to finish in time.

Having some experience with game development it wasn't hard finding the tools for the job. For the text editing I used VS Code, animating with
Aseprite wasn't hard and sfxr made quick work of audio. I usually don't draw, let alone make audio. In spite of that, I'm satisfied with the end
result.
