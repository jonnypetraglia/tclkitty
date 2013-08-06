set tabwidget [ttk::notebook .tabs]


#http://wiki.tcl.tk/460
proc balloon_help {w msg} {
    bind $w <Enter> "after 1000 \"balloon_aux %W [list $msg]\""
    bind $w <Leave> "after cancel \"balloon_aux %W [list $msg]\"
                     after 100 {catch {destroy .balloon_help}}"
}
proc balloon_aux {w msg} {
    set t .balloon_help
    catch {destroy $t}
    toplevel $t
    wm overrideredirect $t 1
    if {$::tcl_platform(platform) == "macintosh"} {
     unsupported1 style $t floating sideTitlebar
    }
    pack [label $t.l -text $msg -relief groove -bd 1 -bg gold] -fill both
    set x [expr [winfo rootx $w]+6+[winfo width $w]/2]
    set y [expr [winfo rooty $w]+6+[winfo height $w]/2]
    wm geometry $t +$x\+$y
    bind $t <Enter> {after cancel {catch {destroy .balloon_help}}}
    bind $t <Leave> "catch {destroy .balloon_help}"
}



################ Tab Main ################
set tabMain [ttk::frame $tabwidget.main]
$tabwidget add $tabMain -text "Main" 
# INPUT FILE
set mainfile_l  [ttk::label $tabMain.mainfile_l -text "Main File"]
set mainfile	[ttk::entry $tabMain.mainfile -width 90]
set mainfile_b  [ttk::button $tabMain.mainfile_b -text "Browse" -command "browseDialog OPEN $mainfile tcl 0"]

grid config $mainfile_l			-row 0 -column 0 -sticky w
grid config $mainfile			-row 1 -column 0 -columnspan 4
grid config $mainfile_b			-row 1 -column 5


# OUTPUT FILE
set outputfolder_l [ttk::label $tabMain.outputfolder_l -text "Output Directory"]
set outputfolder	[ttk::entry $tabMain.outputfolder -width 90]
set outputfolder_b  [ttk::button $tabMain.outputfolder_b -text "Browse" -command "browseDialog FOLDER $outputfolder \"$ExeExtension\" 0"]
 
grid config $outputfolder_l		-row 2 -column 0 -sticky w
grid config $outputfolder			-row 3 -column 0 -columnspan 4
grid config $outputfolder_b		-row 3 -column 5


# ICON
if {$::PLATFORM == $::PLATFORM_WIN || $::PLATFORM ==  $::PLATFORM_MAC} {
    set iconfile_l  [ttk::label $tabMain.iconfile_l -text "Icon File (Optional)"]
    set iconfile	[ttk::entry $tabMain.iconfile -width 90]
    set iconfile_b  [ttk::button $tabMain.iconfile_b -text "Browse" -command {browseDialog OPEN $iconfile $IconExtension 0}]
    
    grid config $iconfile_l		-row 4 -column 0 -sticky w
    grid config $iconfile		-row 5 -column 0 -columnspan 4
    grid config $iconfile_b		-row 5 -column 5
}


set spinnerList [list BackSpace Delete Prior Next Right Left Up Down]

################ Tab Win ################
if {$::PLATFORM == $::PLATFORM_WIN} {
    set tabWin [ttk::frame $tabwidget.windows]
    $tabwidget add $tabWin -text "Windows"
    variable info_fileVersion
    variable info_prodVersion
    
    set infoFrame [ttk::frame $tabWin.infoFrame]
    set info_fileVersion_l [ttk::label $tabWin.infoVersion_l -text "File Version:"]
    grid config $info_fileVersion_l		-row  0 -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=4} {incr i} {
        set info_fileVersion($i)  [ttk::spinbox $infoFrame.infoVersion$i -width 7 -from 0 -to 65535 -justify center]
        grid config $info_fileVersion($i) -row 0 -column $i
        $info_fileVersion($i) set 0
        bind $info_fileVersion($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
    }
    grid config $infoFrame				-row  0 -column 1 -sticky w -columnspan 3
    
    set info_fileDesc_l [ttk::label $tabWin.fileDesc_l -text "File Description"]
    set info_fileDesc   [ttk::entry $tabWin.fileDesc -width 60]
    
    grid config $info_fileDesc_l		-row  1 -column 0 -sticky e -ipadx 10
    grid config $info_fileDesc			-row  1 -column 1 -sticky w -columnspan 3
    
    set prodFrame [ttk::frame $tabWin.prodFrame]
    set info_prodVersion_l [ttk::label $tabWin.prodVersion_l -text "Product Version:"]
    grid config $info_prodVersion_l		-row  2 -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=4} {incr i} {
        set info_prodVersion($i)  [ttk::spinbox $prodFrame.prodVersion$i -width 7 -from 0 -to 65535 -justify center]
        grid config $info_prodVersion($i) -row 0 -column $i
        $info_prodVersion($i) set 0
        bind $info_prodVersion($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
    }
    grid config $prodFrame				-row  2 -column 1 -sticky w -columnspan 3
    
    set info_prodName_l [ttk::label $tabWin.prodName_l -text "Product name"]
    set info_prodName   [ttk::entry $tabWin.prodName -width 60]
    grid config $info_prodName_l		-row  3 -column 0 -sticky e -ipadx 10
    grid config $info_prodName			-row  3 -column 1 -sticky w -columnspan 3
    
    set info_origName_l [ttk::label $tabWin.origName_l -text "Original File Name"]
    set info_origName   [ttk::entry $tabWin.origName -width 30]
    grid config $info_origName_l		-row  4 -column 0 -sticky e -ipadx 10
    grid config $info_origName			-row  4 -column 1 -sticky w -columnspan 3
    
    set info_company_l [ttk::label $tabWin.company_l -text "Company Name"]
    set info_company   [ttk::entry $tabWin.company -width 50]
    grid config $info_company_l			-row  5 -column 0 -sticky e -ipadx 10
    grid config $info_company			-row  5 -column 1 -sticky w -columnspan 3
    
    set info_copyright_l [ttk::label $tabWin.copyright_l -text "Copyright"]
    set info_copyright   [ttk::entry $tabWin.copyright -width 30]
    grid config $info_copyright_l		-row  6 -column 0 -sticky e -ipadx 10
    grid config $info_copyright			-row  6 -column 1 -sticky w -columnspan 3
}

proc toggleControl {var ctrls} {
    foreach ctrl $ctrls {
        if {$var == 1} {
            $ctrl configure -state normal
        } else {
            $ctrl configure -state disabled
        }
    }
}

################ Tab Mac ################
if {$::PLATFORM == $::PLATFORM_MAC} {
    variable macInfoEnabled ;# Array
    variable macVersion
    variable macVersionrel

    set tabMac [ttk::frame $tabwidget.mac]
    $tabwidget add $tabMac -text "Mac"
    
    set ALLTheMacWidgets [list]
    
    #CFBundleName
    incr row
    set info_name_l [ttk::label $tabMac.name_l -text "App Name"]
    set info_name   [ttk::entry $tabMac.name -width 30]
    grid config $info_name_l			-row  $row -column 0 -sticky e -ipadx 10
    grid config $info_name				-row  $row -column 1 -sticky w -columnspan 3
    balloon_help $info_name "Name of the application"
    lappend ALLTheMacWidgets $info_name
    
    
    #CFBundleVersion                (1)
    incr row
    set infoFrame [ttk::frame $tabMac.infoFrame]
    set info_version_l [ttk::checkbutton $tabMac.version_l -text "Build Version" -variable macInfoEnabled(version) -command {toggleControl $macInfoEnabled(version) [list $macVersion(1) $macVersion(2) $macVersion(3)]}]
    grid config $info_version_l		-row  $row -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=3} {incr i} {
        set macVersion($i)  [ttk::spinbox $infoFrame.macVersion$i -width 7 -from 0 -to 65535 -justify center]
        grid config $macVersion($i) -row 0 -column $i
        $macVersion($i) set 0
        bind $macVersion($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
        balloon_help $macVersion($i) "Build Version of the application"
    }
    grid config $infoFrame				-row  $row -column 1 -sticky w -columnspan 3
    set macInfoEnabled(version) 1
    lappend ALLTheMacWidgets $info_version_l $macVersion(1) $macVersion(2) $macVersion(3)
    
    #CFBundleShortVersionString     (1.0.0)
    incr row
    set infoFrame [ttk::frame $tabMac.infoFrame2]
    set info_relversion_l [ttk::checkbutton $tabMac.relversion_l -text "Release Version" -variable macInfoEnabled(relversion) -command {toggleControl $macInfoEnabled(relversion) [list $macVersionrel(1) $macVersionrel(2) $macVersionrel(3)]}]
    grid config $info_relversion_l		-row  $row -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=3} {incr i} {
        set macVersionrel($i)  [ttk::spinbox $infoFrame.macVersionrel$i -width 7 -from 0 -to 65535 -justify center]
        grid config $macVersionrel($i) -row 0 -column $i
        $macVersionrel($i) set 0
        bind $macVersionrel($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
        balloon_help $macVersionrel($i) "Release Version of the application"
    }
    grid config $infoFrame				-row  $row -column 1 -sticky w -columnspan 3
    set macInfoEnabled(relversion) 1
    lappend ALLTheMacWidgets $info_relversion_l $macVersionrel(1) $macVersionrel(2) $macVersionrel(3)
    
    
    #CFBundleIdentifier     (com.qweex.tclkitty)
    incr row
    set info_id_l [ttk::checkbutton $tabMac.id_l -text "Identifier" -variable macInfoEnabled(id) -command {toggleControl $macInfoEnabled(id) $info_id}]
    set info_id   [ttk::entry $tabMac.id -width 30]
    grid config $info_id_l				-row  $row -column 0 -sticky e -ipadx 10
    grid config $info_id				-row  $row -column 1 -sticky w -columnspan 3
    balloon_help $info_id "Unique reverse DNS format string for your app (com.example.app)"
    set macInfoEnabled(id) 1
    lappend ALLTheMacWidgets $info_id_l $info_id
    
    #CFBundleDevelopmentRegion
    incr row
    set info_region_l [ttk::checkbutton $tabMac.region_l -text "Dev Region" -variable macInfoEnabled(region) -command {toggleControl $macInfoEnabled(region) $info_region}]
    set info_region   [ttk::entry $tabMac.region -width 30]
    grid config $info_region_l			-row  $row -column 0 -sticky e -ipadx 10
    grid config $info_region			-row  $row -column 1 -sticky w -columnspan 3
    balloon_help $info_region "Native language of the author (you)"
    set macInfoEnabled(region) 1
    lappend ALLTheMacWidgets $info_region_l $info_region
    
    #CFBundleInfoDictionaryVersion (1.0)
    incr row
    set info_dict_l [ttk::checkbutton $tabMac.dict_l -text "Dictionary Version" -variable macInfoEnabled(dict) -command {toggleControl $macInfoEnabled(dict) $info_dict}]
    set info_dict  [ttk::spinbox $tabMac.dict -width 7 -from 0 -to 65535 -increment 0.01 -justify center]
    grid config $info_dict_l			-row  $row -column 0 -sticky e -ipadx 10
    grid config $info_dict				-row  $row -column 1 -sticky w -columnspan 3
    balloon_help $info_dict "Version of the info in the plist (the stuff here)"
    set macInfoEnabled(dict) 1
    $info_dict set 1.0
    bind $info_dict <KeyPress> { 
        if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
    }
    lappend ALLTheMacWidgets $info_dict_l $info_dict
    
    
    
    #checkbox for creating a mac app
    set row 0
    set createMacApp [ttk::checkbutton $tabMac.createMacApp -text "Create Mac App" -variable createMacApp -command {toggleControl $createMacApp $ALLTheMacWidgets}]
    grid config $createMacApp			-row $row -column 0 -sticky w
    set createMacApp 1
    
    #CFBundleSignature              (TCLKITTY???) ???
    #CFBundleGetInfoString  (Tclkitty 1.0) | deprecated in 10.5


    ######## Menu thingy ########
    menu .menubar
    menu .menubar.apple -tearoff 0
    .menubar.apple add command -label "About Tclkitty" -command about
    .menubar add cascade -label "Apple" -menu .menubar.apple
    . configure -menu .menubar
}

################ Tab Packages ################
set tabPkg [ttk::frame $tabwidget.packages]
$tabwidget add $tabPkg -text "Packages"
# Packages
set pkgFiles_l [ttk::label $tabPkg.pkgFiles_l -text "Packages"]
set pkgFiles   [listbox $tabPkg.pkgFiles -width 90 -selectmode multiple -listvariable pkgFilesList]
set pkgFiles_folder [ttk::button $tabPkg.pkgFiles_adF -text "+Folder" -command "browseDialog FOLDER $pkgFiles {} 1"]
set pkgFiles_remove [ttk::button $tabPkg.pkgFiles_adX -text "-Remove" -command removeExtra]
set pkgFiles_note [ttk::label $tabPkg.extraFiles_note -text "ALL packages you need! These will be stored inside 'lib' on the vfs."]

grid config $pkgFiles_l				-row 0 -column 0 -sticky w
grid config $pkgFiles				-row 1 -column 0 -sticky w -columnspan 3 -rowspan 6
grid config $pkgFiles_folder		-row 1 -column 5 -sticky w
grid config $pkgFiles_remove		-row 2 -column 5 -sticky w
grid config $pkgFiles_note			-row 8 -column 0 -sticky w -columnspan 3 -padx 24


################ Tab Files ################
set tabFiles [ttk::frame $tabwidget.files]
$tabwidget add $tabFiles -text "Files"
# Extra Files
set extraFiles_l [ttk::label $tabFiles.extraFiles_l -text "Files"]
set extraFiles   [listbox $tabFiles.extraFiles -width 90 -selectmode multiple -listvariable extraFilesList]
set extraFiles_file [ttk::button $tabFiles.extraFiles_adf -text "+File" -command "browseDialog OPEN $extraFiles \"*\" 1"]
set extraFiles_folder [ttk::button $tabFiles.extraFiles_adF -text "+Folder" -command "browseDialog FOLDER $extraFiles {} 1"]
set extraFiles_remove [ttk::button $tabFiles.extraFiles_adX -text "-Remove" -command removeExtra]
set extraFiles_note1 [ttk::label $tabFiles.extraFiles_note1 -text "The above files & folders will all be placed in the root directory of the virtual FS"]
set extraFiles_note2 [ttk::label $tabFiles.extraFiles_note2 -text "(To access these files, use '\$starkit::topdir' in your scripts when it is compiled)"]

grid config $extraFiles_l				-row 0 -column 0 -sticky w
grid config $extraFiles					-row 1 -column 0 -sticky w -columnspan 3 -rowspan 6
grid config $extraFiles_file			-row 1 -column 5 -sticky w
grid config $extraFiles_folder			-row 2 -column 5 -sticky w
grid config $extraFiles_remove			-row 3 -column 5 -sticky w
grid config $extraFiles_note1			-row 7 -column 0 -sticky w -columnspan 3 -padx 24
grid config $extraFiles_note2			-row 8 -column 0 -sticky w -columnspan 3 -padx 24



################ Post tabs Files ################
grid config $tabwidget -row 0 -column 0
# Buttons
set buttonbox [ttk::frame .buttons]
set docleanup [ttk::checkbutton $buttonbox.docleanup -text "Cleanup" -variable doCleanup]
set doCleanup 1
set about [ttk::button $buttonbox.about -text "About" -command about]
set build [ttk::button $buttonbox.build -text "Build" -command build]
grid config $docleanup					-row 0 -column 0 -sticky e
grid config $about						-row 0 -column 1 -sticky e
grid config $build						-row 0 -column 2 -sticky w
grid config $buttonbox -row 1 -column 0 -sticky e -ipadx 5 -ipady 5


wm resizable . 0 0
wm title . "tclkitty [info patchlevel]"




proc browseDialog {openOrSaveOrFolder widget extension multifile} {
    global lastBrowseDir
    global extraFiles
    global extraFilesList
    global mainfile
    global outputfolder
    

    if {$extension == "*"} {
        set types [list]
    } else {
        set types_ [list {Files} $extension]
        set types [list $types_]
    }
    
    if {$openOrSaveOrFolder == "FOLDER"} {
        set chosenFile [tk_chooseDirectory -initialdir $lastBrowseDir -mustexist 1]
    } elseif {$openOrSaveOrFolder == "SAVE"} {
        set chosenFile [tk_getSaveFile -initialdir $lastBrowseDir -defaultextension $extension -filetypes $types]
    } else {
        set chosenFile [tk_getOpenFile -initialdir $lastBrowseDir -defaultextension $extension -filetypes $types -multiple $multifile]
    }
    
    if {[string length $chosenFile] == 0} {
        return
    }
    
    if {$widget == $extraFiles} {
        foreach c $chosenFile {
            lappend extraFilesList $c
        }
        set extraFilesList [lsort -unique $extraFilesList]
    } else {
        $widget delete 0 end
        $widget insert 0 $chosenFile
    }
    
    set lastBrowseDir [file dirname $chosenFile]
    
    if {$widget == $mainfile && [string length [$outputfolder get]]==0} {
        $outputfolder delete 0 end
        $outputfolder insert 0 $lastBrowseDir
    }
}

proc removeExtra {} {
    global extraFiles
    global extraFilesList
    set I [lreverse [$extraFiles curselection]]
    foreach i $I {
        set extraFilesList [lreplace $extraFilesList $i $i]
    }
}