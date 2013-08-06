package require Tk


variable ExeExtension
variable KitExtension
variable IconExtension

variable PATH_tclkit
variable PATH_sdx
variable PATH_upx
variable PATH_ResHacker
variable PATH_gorc

set KitExtension .kit
set PATH_sdx "sdx-20110317.kit"

if {$::PLATFORM == $::PLATFORM_WIN} {
    set ExeExtension .exe
    set IconExtension .ico
    
    set PATH_tclcompiler "tclkitsh860.exe"
    set PATH_tclkit "tclkit-gui-860.exe"
    set PATH_upx "upx.exe"
    set PATH_ResHacker "ResHacker.exe"
    set PATH_gorc "GoRC.exe"
    
} elseif {$::PLATFORM == $::PLATFORM_MAC} {
    set ExeExtension ""
    set IconExtension .icns
    set PATH_tclcompiler "tclkit-8.6.0_mac--tk"
    set PATH_tclkit "tclkit-8.6.0_mac--tk-static"
    
} elseif {$::PLATFORM == $::PLATFORM_UNIX} {
    set ExeExtension ""
}


variable lastBrowseDir
set lastBrowseDir .

variable extraFilesList
set extraFilesList [list]
variable pkgFilesList
set pkgFilesList [list]

variable cleanupList
set cleanupList [list]

variable statusVariable
