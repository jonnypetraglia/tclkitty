# tclkitty #
 
tclkitty is a GUI to assist in generating Starkits for Tcl/Tk.

-----------

## Contents: ##
  1. What is a Starkit?
  2. What does tclkitty do?
  3. Using tclkitty
  4. Resources used
 
-----------
 
## 1. What is a Starkit? ##
 
Tcl is interpreted, meaning that you have to have a Tcl runtime installed to run Tcl scripts. For some other interpreted languages -like Python for example- there exists a JIT (Just-In-Time) compiler that will compile the scripts so that they can run on any computer, but Tcl does not have this.

Instead, there are some alternatives that work slightly differently. The terms can be a little confusing, so let's define them:

  - **Tclkit**: A bundle that contains a Tcl runtime. Basically a single file Tcl runtime.
  - **Starkit**: A bundle containing Tcl kits, but still requires local Tcl instance to run. Think of them as Java JAR files, only for Tcl.
  - **Starpack**: A Tclkit + a Starkit. The result is a bundle that has the scripts to run, and the Tcl runtime to run them.

So just to be clear, **a Starpack is _not_ a compiled binary**. It is a virtual filesystem that contains both your Tcl scripts and the Tcl runtime to run them, but the scripts are still interpreted just like regular Tcl.

-----------

## 2. What does tclkitty do? ##

Even though the above solutions exist, it's -by no means- "easy" to figure out how to correctly bundle Tcl into an executable. There are nuances to the virtual filesystem, tricks with what type of tclkit you need, and even when you finally figure it out, it's a hassle to do. It's a multi-step process. On top of that, you have the "extras" for specific platforms, such as application icons for Windows or Mac.

tclkitty is basically a way to automate it all, with using a GUI, and add on some of those platform-specific extras I mentioned.
Along with tclkitty, I will also **supply** tclkits for all the major platforms. One of the biggest hurdles is trying to find a tclkit with a current version of Tcl, and failing that, figuring out how to compile it.

So basically tclkitty does not do anything "new", it just tries to make your life easier. You can also walk through the source code as a kind of guide to "compiling" Tcl if you'd rather do it on your own, or if you just want to learn the steps.

-----------

## 3. Using tclkitty ##

tclkitty __should__ be pretty straightforward, but there are a few tricks you need to know.

### Main Tab ###
  - **Main File**: The main script file for your program. I.e., when you run it with regular Tcl, this is the script file you pass to tclsh.
  - **Output Directory**: The directory that the executable will be placed at.
  - **Icon File (Optional)**: For Mac, this is a ICNS file, for Windows it is a ICO file.
  
### Windows Tab (Optional) ###
If you are on Windows, these options are shown when you right click an EXE and go to the "Details" tab.

### Mac Tab (Optional) ###
  - **Create Mac App**: Will bundle you executable in a *.app file.
  - **Build/Release Version**: Used by OSX....I think....
  - **Identifier**: ???
  - **Dev Region**: ???
  - **Dictionary Version**: ???
  
  
### Packages ###
This is where you will place all your extra Tcl packages. Note that tclkits contain some packages, and the packages available to you depend on what Tclkit you use. You can determine this by running the tclkit and running `package names`. (The packages included in the supplied tclkits are further down in the Readme.)


### Files ###
Here is where you will add files and folders you want in your virtual filesystem.
**This includes all your script files.**

### Cleanup ###
During "compilation", intermediary files are created. Checking this box will remove them after the "compilation" is completed.

### About ###
Display info about tclkitty.

### Build ###
Perform the build!

-----------

## 4. Resources used ##

tclkitty uses several other programs to perform/assist in the "compilation".

  - **Tcl "compiler"**: It needs a local version of Tcl to actually do the compiling.
  - **Tclkit**: It needs a tclkit to be included in the resultant Starpack.
  - **SDX**: It needs the Starkit Developer eXtension to actually do the wrapping
  - **UPX**: It needs UPX on Windows to help compress the executable.
  - **ResHacker**: It needs ResourceHacker on Windows to do extras like setting the icon and file information.
  - **GoRC**: It needs GoRC on Windows to help package the RC files.

### Supplied resources ###
To make things easier, I'm supplying some of the resources above, especially the Tclkits needed on multiple platforms.

There are some tricky things, and, to be honest, it's been a while since I compiled some of them, so I can't rightly remember all the nuaces. Basically there are four types: tclkit*.exe -cli, -sh and -gui. In terms of compiling, you can choose what of the four types it is, what packages it will contain, and whether or not you want to compile it statically.

  - Mac: I compiled these just tclkitty.
  - Windows
    - "Compiler" & tclkit
	  - http://www.patthoyts.tk/tclkit/win32-ix86/8.6.0/
	  - tclkitsh860.exe & tclkit-gui-860.exe
	- SDX 2008-02-24
	  - http://equi4.com/pub/sk/
	  - License: ????
	- UPX v3.91w
	  - http://upx.sourceforge.net
	  - License: GPLv2
	- ResHacker v3.6.0.92
	  - http://www.angusj.com/resourcehacker/
	  - License: Freeware
	- GoRC v1.0.0
	  - http://www.godevtool.com/
	  - License: Non-commercial freeware

#### Packages included in the supplied tclkits ####
Not going to lie, not very sure on this, but here's a running list:

  - Mac:
    - rechan zlib Tcl00 tcl::tommath vfslib vfs::mk4 Tk Mk4tcl vfs Tcl
	

-----------

## Virtual Filesystem Overview **

  - /lib