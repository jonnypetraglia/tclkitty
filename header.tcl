set ::PLATFORM_MAC "macosx"
set ::PLATFORM_WIN "windows"
set ::PLATFORM_UNIX "unix"

set ::PLATFORM $::PLATFORM_WIN	;#TODO This should not be necessary
switch $tcl_platform(platform) {
    "unix" {
        if {$tcl_platform(os) == "Darwin"} {
            set ::PLATFORM $::PLATFORM_OSX
        } else {
            set ::PLATFORM $::PLATFORM_UNIX
        }
    }
    "windows" {
        set ::PLATFORM $::PLATFORM_WIN
    }
}


# TODO: Spinners for 0.0.0.0


package require Tk


variable ExeExtension
variable KitExtension
variable IconExtension

variable PATH_tclkit
variable PATH_sdx
variable PATH_upx
variable PATH_ResHacker
variable PATH_gorc

if {$::PLATFORM == $::PLATFORM_WIN} {
	set ExeExtension .exe
	set KitExtension .kit
	set IconExtension .ico
	
	set PATH_tclcompiler "tclkitsh860.exe"
	set PATH_tclkit "tclkit-gui-860.exe"
	set PATH_sdx "sdx-20110317.kit"
	set PATH_upx "upx.exe"
	set PATH_ResHacker "ResHacker.exe"
	set PATH_gorc "GoRC.exe"
	
} elseif {$::PLATFORM == $::PLATFORM_MAC} {
	set ExeExtension ""
	set IconExtension icns
} elseif {$::PLATFORM == $::PLATFORM_UNIX} {
	set ExeExtension ""
}


variable lastBrowseDir
set lastBrowseDir .

variable extraFilesList
set extraFilesList [list]

variable cleanupList
set cleanupList [list]