set ::PLATFORM_MAC "macosx"
set ::PLATFORM_WIN "windows"
set ::PLATFORM_UNIX "unix"

set ::PLATFORM $::PLATFORM_WIN	;#TODO This should not be necessary
switch $tcl_platform(platform) {
    "unix" {
        if {$tcl_platform(os) == "Darwin"} {
            set ::PLATFORM $::PLATFORM_MAC
        } else {
            set ::PLATFORM $::PLATFORM_UNIX
        }
    }
    "windows" {
        set ::PLATFORM $::PLATFORM_WIN
    }
}


variable APP_DIR
variable REAL_DIR
variable res_dir
if [info exists starkit::topdir] {
    set REAL_DIR "[file normalize $starkit::topdir/..]"
    set APP_DIR $starkit::topdir
    # If it is inside of an APP bundle, point res_dir to the Contents/Resources directory
    if {$::PLATFORM == $::PLATFORM_MAC && [regexp {^.*.app$} [file normalize $REAL_DIR/../..]]} {
        set res_dir [file normalize $REAL_DIR/../Resources]
    } else {
        set res_dir $REAL_DIR/resources
    }
} else {
    set REAL_DIR "[file normalize [pwd]/]"
    set APP_DIR $REAL_DIR
    set res_dir $REAL_DIR/resources
}

source $APP_DIR/header.tcl
source $APP_DIR/gui.tcl
source $APP_DIR/importexport.tcl


proc build {} {
    global APP_DIR
    global res_dir
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
    
    global createMacApp
    global info_prodVersion
    global info_fileVersion
    global macVersion
    global macVersionrel
    global info_id
    global info_name
    global macInfoEnabled

    
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
    #MERC
    set maxVals [list 0 429496 99 99]
    if {$::PLATFORM == $::PLATFORM_MAC && $createMacApp} {
        # Check Mac Version & Release Version
        for {set i 1} {$i<=3} {incr i} {
            set x [$macVersion($i) get]
            if {[string length $x]==0} {
                $macVersion($i) set 0
            } else {
                if {![string is integer $x] || $x<0 || $x>[lindex $maxVals $i]} {
                    tk_messageBox -icon error -title "Invalid Value" -message "Bad value in the Build Version:\n\n$x\n\n(Maximum is [lindex $maxVals $i])"
                    return
                }
            }
            set x [$macVersionrel($i) get]
            if {[string length $x]==0} {
                $fileVersionrel($i) set 0
            } else {
                if {![string is integer $x] || $x<0 || $x>[lindex $maxVals $i]} {
                    tk_messageBox -icon error -title "Invalid Value" -message "Bad value in the Release Versions:\n\n$x\n\n(Maximum is [lindex $maxVals $i])"
                    return
                }
            }
        }
        # Check name 
        set x [$info_name get]
        if {[string length $x] == 0} {
            tk_messageBox -icon error -title "Invalid Value" -message "You must enter an App Name"
            return
        }
        # Check identifier is valid
        set x [$info_id get]
        if {$macInfoEnabled(id) && [regexp {^[a-zA-Z\-\.]*$} $x] == 0} {
            tk_messageBox -icon error -title "Invalid Value" -message "Bad value in the Identifier:\n\n$x\n\n(Can only contain A-Z, a-z, - and .)"
            return
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
    exec "$res_dir/$PATH_tclcompiler" "$res_dir/$PATH_sdx" qwrap "$Vmainfile"
    if {![file exists $kitfile]} {
        cleanup "Error" "kitfile"
        return
    }
    lappend cleanupList $kitfile
    
    ################### Unwrap .kit ###################
    set statusVariable "Unwrapping starkit file:    $vfsfolder"
    exec "$res_dir/$PATH_tclcompiler" "$res_dir/$PATH_sdx" unwrap "$kitfile"
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
    exec "$res_dir/$PATH_tclcompiler" "$res_dir/$PATH_sdx" wrap "$outputexe" "-runtime" "$res_dir/$PATH_tclkit"
    if {![file exists $outputexe]} {
        cleanup "Error" "final exe"
        return
    }
    
    if {$::PLATFORM == $::PLATFORM_WIN} {
        windowsIconAndInfo $Viconfile $filenameMinusExtension
        file rename -force -- $outputexe $Voutputfolder/.
        cleanup "Info" "Successfully generated:\n$Voutputfolder/[getFilename $outputexe]"
    }
    
    if {$::PLATFORM == $::PLATFORM_MAC && $createMacApp} {
        if {$createMacApp} {
            file delete -force -- $Voutputfolder/[$info_name get].app
            macCreateApp $Viconfile $filenameMinusExtension $Voutputfolder
            cleanup "Info" "Successfully generated:\n$Voutputfolder/[$info_name get].app"
        } else {
            file rename -force -- $outputexe $Voutputfolder/.
            cleanup "Info" "Successfully generated:\n$Voutputfolder/[getFilename $outputexe]"
        }
    }
}

proc cleanup {reasonType reasonMsg} {
    global cleanupList
    global doCleanup
    set statusVariable "Cleaning up..."
    puts "DERP $doCleanup"
    if {$doCleanup} {
        foreach f $cleanupList {
            file delete -force -- $f
        }
    }
    wm withdraw .statusDialog 
    tk_messageBox -icon [string tolower $reasonType] -message $reasonMsg -title $reasonType
}

proc macCreateApp {iconfile filenameMinusExtension outputfolder} {
    global ExeExtension
    global info_name
    global macVersion
    global macVersionrel
    global info_region
    global info_id
    global info_dict
    global macInfoEnabled

    #From GUI
        set CFBundleName [$info_name get]
        set CFBundleVersion "[$macVersion(1) get].[$macVersion(2) get].[$macVersion(3) get]"
        set CFBundleShortVersionString "[$macVersionrel(1) get].[$macVersionrel(2) get].[$macVersionrel(3) get]"
        set CFBundleDevelopmentRegion [$info_region get]
        set CFBundleIdentifier [$info_id get]
        set CFBundleInfoDictionaryVersion [$info_dict get]
        set CFBundleIconFile [getFilename $iconfile]
        #CFBundleSignature???
        #CFBundleGetInfoString???

    #Calculated
        set CFBundleExecutable $filenameMinusExtension$ExeExtension

    #Misc
        set CFBundlePackageType "APPL"
        set LSRequiresCarbon "true"
        set NSAppleScriptEnabled "false"
        set LSMinimumSystemVersion "10.4.0"
    
    # 1. Make directory structure
    set statusVariable "Creating Mac directory structure"
    file mkdir $outputfolder/$CFBundleName.app
    file mkdir $outputfolder/$CFBundleName.app/Contents
    file mkdir $outputfolder/$CFBundleName.app/Contents/MacOs
    file mkdir $outputfolder/$CFBundleName.app/Contents/Resources
    # 2. Copy $iconfile
    if {[string length $iconfile] > 0} {
        set statusVariable "Copying Mac icon file"
        file copy -force -- $iconfile $outputfolder/$CFBundleName.app/Contents/Resources/$CFBundleIconFile
    }
    # 3. Move
    set statusVariable "Copying application to Mac package"
    file rename -force -- $filenameMinusExtension$ExeExtension $outputfolder/$CFBundleName.app/Contents/MacOs/$CFBundleExecutable
    # 4. Create plist
    set statusVariable "Creating the plist file"
    set fileId [open "$outputfolder/$CFBundleName.app/Contents/Info.plist" "w"]
    
    puts $fileId        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts $fileId        "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
    puts $fileId        "<plist version=\"1.0\">"
    puts $fileId        "<dict>"
    puts $fileId        "	<key>CFBundleName</key>"
    puts $fileId        "	<string>$CFBundleName</string>"
    if {$macInfoEnabled(version)} {
        puts $fileId    "	<key>CFBundleVersion</key>"
        puts $fileId    "	<string>$CFBundleVersion</string>"
    }
    if {$macInfoEnabled(relversion)} {
        puts $fileId    "	<key>CFBundleShortVersionString</key>"
        puts $fileId    "	<string>$CFBundleShortVersionString</string>"
    }
    if {$macInfoEnabled(id)} {
        puts $fileId    "	<key>CFBundleIdentifier</key>"
        puts $fileId    "	<string>$CFBundleIdentifier</string>"
    }
    if {$macInfoEnabled(region)} {
        puts $fileId    "	<key>CFBundleDevelopmentRegion</key>"
        puts $fileId    "	<string>$CFBundleDevelopmentRegion</string>"
    }
    if {$macInfoEnabled(dict)} {
        puts $fileId    "	<key>CFBundleInfoDictionaryVersion</key>"
        puts $fileId    "	<string>$CFBundleInfoDictionaryVersion</string>"
    }

    puts $fileId        "	<key>CFBundleExecutable</key>"
    puts $fileId        "	<string>$CFBundleExecutable</string>"
    if {[string length $iconfile] > 0} {
        puts $fileId        "	<key>CFBundleIconFile</key>"
        puts $fileId        "	<string>$CFBundleIconFile</string>"
    }
    puts $fileId        "	<key>CFBundlePackageType</key>"
    puts $fileId        "	<string>$CFBundlePackageType</string>"
    puts $fileId        "	<key>LSRequiresCarbon</key>"
    puts $fileId        "	<$LSRequiresCarbon/>"
    puts $fileId        "	<key>NSAppleScriptEnabled</key>"
    puts $fileId        "	<$NSAppleScriptEnabled/>"
    puts $fileId        "	<key>LSMinimumSystemVersion</key>"
    puts $fileId        "	<string>$LSMinimumSystemVersion</string>"

    puts $fileId        "</dict>"
    puts $fileId        "</plist>"
    close $fileId
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
    global res_dir
    
    # Uncompress with UPX
    set statusVariable "Uncompressing with UPX"
    exec $res_dir/$PATH_upx "-d" $filenameMinusExtension$ExeExtension
    
    # ResHacker to remove version & icons
    set statusVariable "Removing information & icons with ResHacker"
    exec $res_dir/$PATH_ResHacker "-delete" "$filenameMinusExtension$ExeExtension" "," "$filenameMinusExtension$ExeExtension" "," "versioninfo" "," ","
    exec $res_dir/$PATH_ResHacker "-delete" "$filenameMinusExtension$ExeExtension" "," "$filenameMinusExtension$ExeExtension" "," "icongroup" "," ","
    
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
    exec $res_dir/$PATH_gorc /r "tclkitty.rc"
    lappend cleanupList "tclkitty.rc"
    lappend cleanupList "tclkitty.res"
    
    # Add Res
    set statusVariable "Adding RES to executable"
    exec $res_dir/$PATH_ResHacker -add $filenameMinusExtension$ExeExtension , $filenameMinusExtension$ExeExtension , tclkitty.res , ,,
    
    set statusVariable "Re-compressing with UPX"
    exec $res_dir/$PATH_upx $filenameMinusExtension$ExeExtension
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
