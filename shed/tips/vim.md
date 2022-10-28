# Ethan's Vim Life

In general, my Vim philosiphy is to try to keep my Vim experience as vanilla as possible. This has
a multitude of benefits which I enjoy:
- By sticking to Vim built-in mechanisms, I am using Vim in the way Bram (author of Vim) intended.
- My Vim experience can't be dominated and ruined by a single plugin or a couple plugins.
- Most importantly, the lack of freebie tools means that as a developer I need to actually know
  what the heck I am doing. Mainly I can't just fuzzy find and hop to random files, I
  actually need to know where they are located in the project structure and why.

As a lifelong JetBrains IDE (IntelliJ, Android Studio, CLion) user, going from having every tool
at my disposal to almost having nothing can feel a bit weird. But I decided to learn the dark
arts of Vim since I kept blaming my IDE for all of my problems:
- I was so terrible at navigating my cursor through code to the point that I preferred having a 
  smaller keyboard so that my mouse was closer to access for quick cusor movements.
- I was constantly asking my IDE for permission before I wrote new chunks of code since I was an
  extremely heavy user of code completion. When my IDE's code completion suggestions fell apart, I 
  fell apart with it.
- After years of IDE-based coding, I realized that I was turning into the developer that my IDE
  wanted me to be instead of the developer that I wanted to be. If my IDE wanted me to be fast at 
  something, I would become fast at it. Otherwise I was slow because my IDE wasn't flexible enough.
  
I had some extra time while working on projects at Google, so I challenged myself to see whether
my own "code completion" was better than my old IDE's and whether I could be much more productive
and effective without the distractions of random tool panes and options.

## Rules
The Vim solutions I use must follow these rules:
- Use Vim built-in functionaity as much as possible.
- Only use .vimrc to set options (which I restrict to less than 50 options)
- If something can't be done in Vim, likely it shouldn't be done in Vim. My config encourages me
  to use purpose-built commands and tools outside of Vim.
- Plugins must solve a problem which Vim has 0% solved and which I could still bear living with.
- Additional `.vim` files can configure additiona built-in Vim features. However, each Vim feature 
  can only be used for a singular purpose since I don't want a single feature to dominate my 
  experience (and dictate my developer workflow).

## Solutions
Using Vim full-time has forced me to use all of Vim's features in one interesting way or another.
When all combined together, they can satisify my basic needs as a dev.

### Navigation
My solution to navigating across code files is three-fold:
1. I use the `:Vex` vim command to open a file explorer somewhat similar to modern IDEs. This
   allows me to explore new project structures I may not be very fimilar with. Then I have netrw
   set up so that selecting a file opens it in my current editor split. The netrw file explorer
   has an option for seeing an entire directory tree but honestly I think it sucks. The reduced 
   screen cluster of only seeing a single folder's contents is awesome.

2. I use `:e` super-duper heavily. Well `:e` only opens a file at an exact file path so how could it
   possibly be a replacement for file search? Oh boy was this a big shocker to me. It turned out
   that in my IDE I wasted a lot of time entering random long file paths since all build config
   files have the same name. I was only enetering 2-3 extra folders in my search but it was still
   annoying. 

   My solution to this problem is to have a trillion zsh environment variables which are shortened
   file paths to important locaitons. All I have to do is enter in `:e $f3/build.gradle` instead of 
   searching for folder1/folder2/folder3/build.gradle. It has been a tremendous time saver for me. 
   I'm guaranteed to go to the spot I'm thining of, I better remember the location and why I find
   it important (now that it isn't a blur of slashes) and I can use the variables outside of Vim
   too so that I can `cd` into the folder to do other things.

   Best of all is that I have wildmode enabled in my Vim config, which allows for tab autcompletion
   in commands like `:e`. Reguarly, I don't even need to type in the file name itself, just a
   variable like `:e $f3/` (then tab). 

3. `:b` works like `:e` except it can access files (buffers) that I already have opened. If I ever get
   tired of the environment variable shenanigans then I can simply use wildmode with `:b` to 
   autocomplete part of a file name. Only having this file name autocomplete apply to opened files
   is great because there are few enough files were it is fast and accurate. Before using `:b` I
   would constantly use Ctrl+Tab to cycle through my windows in my IDE which was mentally very
   tiring.

## Sooner or Later...
Here are some solutions I am yet to implement to improve my editor experience:
- Consistent file formatting tool using a megalinter
- Entering code/file templates using abbreviations
- Zsh command to locate relative file spots (ex. test module, build file)
- Quick importing by having variables for common import packages
- Documentation-based go-to-definition for framework symbols and import based go-to-defintion for
  local symbols using a custom g command
- Interesting opening prompt that shows a cool message
