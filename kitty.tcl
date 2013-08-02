variable APP_DIR
if [info exists starkit::topdir] {
    set APP_DIR $starkit::topdir
} else {
    set APP_DIR "[file normalize [pwd]/[file dirname [info script]]]"
}

source $APP_DIR/header.tcl
source $APP_DIR/gui.tcl

# Download tclkit:
#    http://www.patthoyts.tk/tclkit
#    http://www.openverse.com/~lilith/TCL/
#    http://equi4.com/pub/tk/
# SDX commands:
#    http://wiki.tcl.tk/3411
# Building tclkit:
#    http://code.google.com/p/tclkit/issues/detail?id=11
#    http://code.google.com/p/tclkit/wiki/BuildingTclkit

# TODO:
#        x86 vs x64 RadioButton
#        sdx options for final wrapping
#            -nocomp        Do not compress files added to starkit
#            -writable    Allow modifications (must be single writer)

proc build {} {
    global APP_DIR
    global PATH_tclkit
    global PATH_tclcompiler
    global PATH_sdx
    
    global mainfile
    global outputfolder
    global iconfile
    
    global extraFilesList
    global pkgFilesList
    global cleanupList
    global ExeExtension
    
    global info_prodVersion
    global info_fileVersion
    
    ################### Get string things ###################
    # Get info from gui
    set Vmainfile [$mainfile get]
    set Voutputfolder [$outputfolder get]
    set Viconfile [$iconfile get]
    
    set filenameMinusExtension [getFilenameWithoutExtension $Vmainfile]
    set kitfile $filenameMinusExtension.kit    
    set vfsfolder $filenameMinusExtension.vfs
    set outputexe $filenameMinusExtension$ExeExtension
    set tempfolder "TMP_BUILD"
    
    # CD to dir
    cd "[file dirname $Vmainfile]"
    
    #### Sanity Check ####
    if {![file exists $Vmainfile]} {
        tk_messageBox -icon error -title "File not Found" -message "Main File does not exist"
        return
    }
    if {[ catch {file mkdir $Voutputfolder} ]} {
        tk_messageBox -icon error -title "File not Found" -message "Folder for output file is inaccessible"
        return
    }
    if {[string length $Viconfile]>0} {
        if {![file exists $Viconfile]} {
            tk_messageBox -icon error -title "File not Found" -message "Icon File does not exist"
            return
        }
    }
    
    ### WOMBOWS ###
    if {$::PLATFORM == $::PLATFORM_WIN} {
        for {set i 1} {$i<=4} {incr i} {
            set x [$info_prodVersion($i) get]
            if {[string length $x]==0} {
                $info_prodVersion($i) set 0
            } else {
                if {![string is integer $x] || $x<0 || $x>65535} {
                    tk_messageBox -icon error -title "Invalid Value" -message "Bad value in the ProductVersion:\n\n$x\n\n(Maximum is 65535)"
                    return
                }
            }
            set x [$info_fileVersion($i) get]
            if {[string length $x]==0} {
                $info_fileVersion($i) set 0
            } else {
                if {![string is integer $x] || $x<0 || $x>65535} {
                    tk_messageBox -icon error -title "Invalid Value" -message "Bad value in the ProductVersion:\n\n$x\n\n(Maximum is 65535)"
                    return
                }
            }
        }
    }


    showStatus
    update idletasks

    #### Clean ####
    set statusVariable "Cleaning up any leftovers from last time..."
    file delete -force -- $vfsfolder
    file delete -force -- $kitfile
    file delete -force -- $outputexe
    file delete -force -- $tempfolder
    
    ################### Create .kit ###################
    set statusVariable "Creating starkit file:        $kitfile"
    exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" qwrap "$Vmainfile"
    if {![file exists $kitfile]} {
        cleanup "Error" "kitfile"
        return
    }
    lappend cleanupList $kitfile
    
    ################### Unwrap .kit ###################
    set statusVariable "Unwrapping starkit file:    $vfsfolder"
    exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" unwrap "$kitfile"
    if {![file exists $vfsfolder]} {
        cleanup "Error" "vfs folder"
        return
    }
    lappend cleanupList $vfsfolder

    ################### Copy extra files ###################
    foreach f $extraFilesList {
        set statusVariable "Copying file:    $f"
        set newfile "$vfsfolder/[getFilename $f]"
        file copy $f $newfile
        if {![file exists $newfile]} {
            cleanup "Error" "xtra files:   $f"
            return
        }
    }
    
    ################### Copy packages ###################
    foreach f $pkgFilesList {
        set statusVariable "Copying package:    $f"
        set newfile "$vfsfolder/lib/[getFilename $f]"
        file copy $f $newfile
        if {![file exists $newfile]} {
            cleanup "Error" "xtra files:   $f"
            return
        }
    }

    ################### Re-wrap ###################
    set statusVariable "Final re-wrapping:        $outputexe"
    exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" wrap "$outputexe" "-runtime" "$APP_DIR/resources/$PATH_tclkit"
    if {![file exists $outputexe]} {
        cleanup "Error" "final exe"
        return
    }
    
    if {$::PLATFORM == $::PLATFORM_WIN} {
        windowsIconAndInfo $Viconfile $filenameMinusExtension
    } elseif {$::PlATFORM == $::PLATFORM_MAC} {
        exec $APP_DIR/resources/$PATH_upx $filenameMinusExtension$ExeExtension
    }
    cleanup "Info" "Successfully generated:\n$outputexe"
}

proc cleanup {reasonType reasonMsg} {
    global cleanupList
    set statusVariable "Cleaning up..."
    foreach f $cleanupList {
        puts "file delete -force -- $f"
    }
    wm withdraw .statusDialog 
    tk_messageBox -icon [string tolower $reasonType] -message $reasonMsg -title $reasonType
}

proc windowsIconAndInfo {iconFile filenameMinusExtension} {
    global info_fileVersion
    global info_fileDesc
    global info_prodVersion
    global info_prodName
    global info_origName
    global info_company
    global info_copyright
    global cleanupList
    
    global PATH_ResHacker
    global PATH_gorc
    global PATH_upx
    global ExeExtension
    global APP_DIR
    
    # Uncompress with UPX
    set statusVariable "Uncompressing with UPX"
    exec $APP_DIR/resources/$PATH_upx "-d" $filenameMinusExtension$ExeExtension
    
    # ResHacker to remove version & icons
    set statusVariable "Removing information & icons with ResHacker"
    exec $APP_DIR/resources/$PATH_ResHacker "-delete" "$filenameMinusExtension$ExeExtension" "," "$filenameMinusExtension$ExeExtension" "," "versioninfo" "," ","
    exec $APP_DIR/resources/$PATH_ResHacker "-delete" "$filenameMinusExtension$ExeExtension" "," "$filenameMinusExtension$ExeExtension" "," "icongroup" "," ","
    
    set statusVariable "Creating RC file"
    set fileId [open "tclkitty.rc" "w"]
    if {[string length $iconFile] > 0} {
        set iconFile [string map {"/" "\\"} $iconFile]
        puts $fileId "APPICONS ICON \"$iconFile\""
        puts $fileId "TK ICON \"$iconFile\""
    }
    puts $fileId         "1 VERSIONINFO"
    puts $fileId         "FILEVERSION [$info_fileVersion(1) get], [$info_fileVersion(2) get], [$info_fileVersion(3) get], [$info_fileVersion(4) get]"
    puts $fileId         "PRODUCTVERSION [$info_fileVersion(1) get], [$info_fileVersion(2) get], [$info_fileVersion(3) get], [$info_fileVersion(4) get]"
    puts $fileId         "FILEOS 4"
    puts $fileId         "FILETYPE 1"
    puts $fileId         "{"
    puts $fileId         "    BLOCK \"StringFileInfo\" {"
    puts $fileId         "        BLOCK \"040904b0\" {"
    if {[string length [$info_fileDesc get]] > 0} {
        puts $fileId     "            VALUE \"FileDescription\", \"[$info_fileDesc get]\""
    }
    if {[string length [$info_origName get]] > 0} {
        puts $fileId     "            VALUE \"OriginalFilename\", \"[$info_origName get]\""
    }
    if {[string length [$info_company get]] > 0} {
        puts $fileId     "            VALUE \"CompanyName\", \"[$info_company get]\""
    }
    if {[string length [$info_copyright get]] > 0} {
        puts $fileId     "            VALUE \"LegalCopyright\", \"[$info_copyright get]\""
    }
    if {[string length [$info_prodName get]] > 0} {
        puts $fileId     "            VALUE \"ProductName\", \"[$info_prodName get]\""
    }
    puts $fileId         "            VALUE \"FileVersion\", \"[$info_fileVersion(1) get].[$info_fileVersion(2) get].[$info_fileVersion(3) get].[$info_fileVersion(4) get]\""
    puts $fileId         "            VALUE \"ProductVersion\", \"[$info_fileVersion(1) get].[$info_fileVersion(2) get].[$info_fileVersion(3) get].[$info_fileVersion(4) get]\""
    puts $fileId         "        }"
    puts $fileId         "    }"
    puts $fileId         "    BLOCK \"VarFileInfo\" {"
    puts $fileId         "        VALUE \"Translation\", 0x0409, 0x04B0"
    puts $fileId         "    }"
    puts $fileId         "}"
    close $fileId
    
    # Convert RC to RES
    set statusVariable "Generating RES from RC"
    exec $APP_DIR/resources/$PATH_gorc /r "tclkitty.rc"
    lappend cleanupList "tclkitty.rc"
    lappend cleanupList "tclkitty.res"
    
    # Add Res
    set statusVariable "Adding RES to executable"
    exec $APP_DIR/resources/$PATH_ResHacker -add $filenameMinusExtension$ExeExtension , $filenameMinusExtension$ExeExtension , tclkitty.res , ,,
    
    set statusVariable "Re-compressing with UPX"
    exec $APP_DIR/resources/$PATH_upx $filenameMinusExtension$ExeExtension
}

proc getFilenameWithoutExtension {fn} {
    set a [expr [string length [file dirname $fn]] +1]
    set b [expr [string length $fn] - [string length [file extension $fn]] -1]
    set filenameMinusExtension [string range $fn $a $b]
}

proc getFilename {fn} {
    set a [expr [string length [file dirname $fn]] +1]
    set filenameMinusExtension [string range $fn $a end]
}

proc about {} {
    
}

proc showStatus {} {
    global statusVariable
    
    if [winfo exists .statusDialog] {
        wm withdraw .statusDialog
        wm deiconify .statusDialog
        .statusDialog.bar start
        return
    }
    
    toplevel .statusDialog
    wm title .statusDialog "Status"
    wm resizable .statusDialog 0 0
    
    label .statusDialog.text -textvariable statusVariable
    ttk::progressbar .statusDialog.bar -length 400
    
    pack .statusDialog.text
    pack .statusDialog.bar
    .statusDialog.bar start
    
}
