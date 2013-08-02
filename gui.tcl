set mainframe [ttk::frame .mainframe]

# INPUT FILE
set mainfile_l  [ttk::label $mainframe.mainfile_l -text "Main File"]
set mainfile	[ttk::entry $mainframe.mainfile -width 90]
set mainfile_b  [ttk::button $mainframe.mainfile_b -text "Browse" -command "browseDialog OPEN $mainfile tcl 0"]

grid config $mainfile_l			-row 0 -column 0 -sticky w
grid config $mainfile			-row 1 -column 0 -columnspan 4
grid config $mainfile_b			-row 1 -column 5


# OUTPUT FILE
set outputfolder_l [ttk::label $mainframe.outputfolder_l -text "Output Directory"]
set outputfolder	[ttk::entry $mainframe.outputfolder -width 90]
set outputfolder_b  [ttk::button $mainframe.outputfolder_b -text "Browse" -command "browseDialog FOLDER $outputfolder \"$ExeExtension\" 0"]
 
grid config $outputfolder_l		-row 2 -column 0 -sticky w
grid config $outputfolder			-row 3 -column 0 -columnspan 4
grid config $outputfolder_b		-row 3 -column 5


# ICON
if {$::PLATFORM == $::PLATFORM_WIN || $::PLATFORM ==  $::PLATFORM_MAC} {
    set iconfile_l  [ttk::label $mainframe.iconfile_l -text "Icon File (Optional)"]
    set iconfile	[ttk::entry $mainframe.iconfile -width 90]
    set iconfile_b  [ttk::button $mainframe.iconfile_b -text "Browse" -command {browseDialog OPEN $iconfile $IconExtension 0}]
    
    grid config $iconfile_l		-row 4 -column 0 -sticky w
    grid config $iconfile		-row 5 -column 0 -columnspan 4
    grid config $iconfile_b		-row 5 -column 5
}


variable info_fileVersion
variable info_prodVersion
set spinnerList [list BackSpace Delete Prior Next Right Left Up Down]
# File Info
if {$::PLATFORM == $::PLATFORM_WIN} {
    grid config [ttk::label $mainframe.sep ] -row  6 -column 0 -columnspan 5

    set infoFrame [ttk::frame $mainframe.infoFrame]
    set info_fileVersion_l [ttk::label $mainframe.infoVersion_l -text "File Version:"]
    grid config $info_fileVersion_l		-row  7 -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=4} {incr i} {
        set info_fileVersion($i)  [ttk::spinbox $infoFrame.infoVersion$i -width 7 -from 0 -to 65535 -justify center]
        grid config $info_fileVersion($i) -row 0 -column $i
        $info_fileVersion($i) set 0
        bind $info_fileVersion($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
    }
    grid config $infoFrame				-row  7 -column 1 -sticky w -columnspan 3
    
    set info_fileDesc_l [ttk::label $mainframe.fileDesc_l -text "File Description"]
    set info_fileDesc   [ttk::entry $mainframe.fileDesc -width 60]
    
    grid config $info_fileDesc_l		-row  8 -column 0 -sticky e -ipadx 10
    grid config $info_fileDesc			-row  8 -column 1 -sticky w -columnspan 3
    
    set prodFrame [ttk::frame $mainframe.prodFrame]
    set info_prodVersion_l [ttk::label $mainframe.prodVersion_l -text "Product Version:"]
    grid config $info_prodVersion_l		-row  9 -column 0 -sticky e -ipadx 10
    for {set i 1} {$i<=4} {incr i} {
        set info_prodVersion($i)  [ttk::spinbox $prodFrame.prodVersion$i -width 7 -from 0 -to 65535 -justify center]
        grid config $info_prodVersion($i) -row 0 -column $i
        $info_prodVersion($i) set 0
        bind $info_prodVersion($i) <KeyPress> { 
            if {![string is integer "%K"] && [lsearch $spinnerList "%K"]==-1} break
        }
    }
    grid config $prodFrame				-row  9 -column 1 -sticky w -columnspan 3
    
    set info_prodName_l [ttk::label $mainframe.prodName_l -text "Product name"]
    set info_prodName   [ttk::entry $mainframe.prodName -width 60]
    
    grid config $info_prodName_l		-row 10 -column 0 -sticky e -ipadx 10
    grid config $info_prodName			-row 10 -column 1 -sticky w -columnspan 3
    
    set info_origName_l [ttk::label $mainframe.origName_l -text "Original File Name"]
    set info_origName   [ttk::entry $mainframe.origName -width 30]
    
    grid config $info_origName_l		-row 11 -column 0 -sticky e -ipadx 10
    grid config $info_origName			-row 11 -column 1 -sticky w -columnspan 3
    
    set info_company_l [ttk::label $mainframe.company_l -text "Company Name"]
    set info_company   [ttk::entry $mainframe.company -width 50]
    
    grid config $info_company_l			-row 12 -column 0 -sticky e -ipadx 10
    grid config $info_company			-row 12 -column 1 -sticky w -columnspan 3
    
    set info_copyright_l [ttk::label $mainframe.copyright_l -text "Copyright"]
    set info_copyright   [ttk::entry $mainframe.copyright -width 30]
    
    grid config $info_copyright_l		-row 13 -column 0 -sticky e -ipadx 10
    grid config $info_copyright			-row 13 -column 1 -sticky w -columnspan 3
    
}

grid config [ttk::label $mainframe.sep2 ] -row  14 -column 0 -columnspan 5

# Packages
set pkgFiles_l [ttk::label $mainframe.pkgFiles_l -text "Packages"]
set pkgFiles   [listbox $mainframe.pkgFiles -width 90 -selectmode multiple -listvariable pkgFilesList -height 5]
set pkgFiles_folder [ttk::button $mainframe.pkgFiles_adF -text "+Folder" -command "browseDialog FOLDER $pkgFiles {} 1"]
set pkgFiles_remove [ttk::button $mainframe.pkgFiles_adX -text "-Remove" -command removeExtra]
set pkgFiles_note [ttk::label $mainframe.extraFiles_note -text "ALL packages you need! These will be stored inside 'lib' on the vfs."]

grid config $pkgFiles_l				-row 15 -column 0 -sticky w
grid config $pkgFiles				-row 16 -column 0 -sticky w -columnspan 3 -rowspan 6
grid config $pkgFiles_folder		-row 16 -column 5 -sticky w
grid config $pkgFiles_remove		-row 17 -column 5 -sticky w
grid config $pkgFiles_note			-row 23 -column 0 -sticky w -columnspan 3 -padx 24


# Extra Files
set extraFiles_l [ttk::label $mainframe.extraFiles_l -text "Files"]
set extraFiles   [listbox $mainframe.extraFiles -width 90 -selectmode multiple -listvariable extraFilesList]
set extraFiles_file [ttk::button $mainframe.extraFiles_adf -text "+File" -command "browseDialog OPEN $extraFiles \"*\" 1"]
set extraFiles_folder [ttk::button $mainframe.extraFiles_adF -text "+Folder" -command "browseDialog FOLDER $extraFiles {} 1"]
set extraFiles_remove [ttk::button $mainframe.extraFiles_adX -text "-Remove" -command removeExtra]
set extraFiles_note1 [ttk::label $mainframe.extraFiles_note1 -text "The above files & folders will all be placed in the root directory of the virtual FS"]
set extraFiles_note2 [ttk::label $mainframe.extraFiles_note2 -text "(To access these files, use '\$starkit::topdir' in your scripts when it is compiled)"]

grid config $extraFiles_l				-row 25 -column 0 -sticky w
grid config $extraFiles					-row 26 -column 0 -sticky w -columnspan 3 -rowspan 6
grid config $extraFiles_file			-row 26 -column 5 -sticky w
grid config $extraFiles_folder			-row 27 -column 5 -sticky w
grid config $extraFiles_remove			-row 28 -column 5 -sticky w
grid config $extraFiles_note1			-row 32 -column 0 -sticky w -columnspan 3 -padx 24
grid config $extraFiles_note2			-row 33 -column 0 -sticky w -columnspan 3 -padx 24


# Buttons
set build [ttk::button $mainframe.build -text "Build" -command build]
set about [ttk::button $mainframe.about -text "About" -command about]
grid config $build						-row 36 -column 5 -sticky e
grid config $about						-row 37 -column 5 -sticky e


pack $mainframe -padx 20 -pady 15
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
    
    puts "Last Browse: $lastBrowseDir"
    puts "Browse:      '$types'"
    
    if {$openOrSaveOrFolder == "FOLDER"} {
        set chosenFile [tk_chooseDirectory -initialdir $lastBrowseDir -mustexist 1]
    } elseif {$openOrSaveOrFolder == "SAVE"} {
        set chosenFile [tk_getSaveFile -initialdir $lastBrowseDir -defaultextension $extension -filetypes $types]
    } else {
        set chosenFile [tk_getOpenFile -initialdir $lastBrowseDir -defaultextension $extension -filetypes $types -multiple $multifile]
    }
    
    puts $chosenFile
    
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