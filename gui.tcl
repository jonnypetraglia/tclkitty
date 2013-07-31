set mainframe [ttk::frame .mainframe]

# INPUT FILE
set mainfile_l  [ttk::label $mainframe.mainfile_l -text "Main File"]
set mainfile	[ttk::entry $mainframe.mainfile -width 80]
set mainfile_b  [ttk::button $mainframe.mainfile_b -text "…" -command "browseDialog OPEN $mainfile tcl 0"]

grid config $mainfile_l			-row 0 -column 0 -sticky w
grid config $mainfile			-row 1 -column 0 -columnspan 4
grid config $mainfile_b			-row 1 -column 5


# OUTPUT FILE
set outputfile_l [ttk::label $mainframe.outputfile_l -text "Output File"]
set outputfile	[ttk::entry $mainframe.outputfile -width 80]
set outputfile_b  [ttk::button $mainframe.outputfile_b -text "…" -command "browseDialog SAVE $outputfile \"$ExeExtension\" 0"]
 
grid config $outputfile_l		-row 2 -column 0 -sticky w
grid config $outputfile			-row 3 -column 0 -columnspan 4
grid config $outputfile_b		-row 3 -column 5


# ICON
if {$::PLATFORM == $::PLATFORM_WIN || $::PLATFORM ==  $::PLATFORM_MAC} {
	set iconfile_l  [ttk::label $mainframe.iconfile_l -text "Icon File (Optional)"]
	set iconfile	[ttk::entry $mainframe.iconfile -width 80]
	set iconfile_b  [ttk::button $mainframe.iconfile_b -text "…" -command {browseDialog OPEN $iconfile $IconExtension 0}]
	 
	grid config $iconfile_l		-row 4 -column 0 -sticky w
	grid config $iconfile		-row 5 -column 0 -columnspan 4
	grid config $iconfile_b		-row 5 -column 5
}

# File Info
if {$::PLATFORM == $::PLATFORM_WIN} {
	grid config [ttk::label $mainframe.sep ] -row  6 -column 0 -columnspan 5

	set info_fileVersion_l [ttk::label $mainframe.infoVersion_l -text "File Version:"]
	set info_fileVersion   [ttk::spinbox $mainframe.infoVersion -width 15]
	
	grid config $info_fileVersion_l		-row  7 -column 0 -sticky e -ipadx 10
	grid config $info_fileVersion		-row  7 -column 1 -sticky w -columnspan 3
	
	set info_fileDesc_l [ttk::label $mainframe.fileDesc_l -text "File Description"]
	set info_fileDesc   [ttk::entry $mainframe.fileDesc -width 60]
	
	grid config $info_fileDesc_l		-row  8 -column 0 -sticky e -ipadx 10
	grid config $info_fileDesc			-row  8 -column 1 -sticky w -columnspan 3
	
	set info_prodVersion_l [ttk::label $mainframe.prodVersion_l -text "Product Version:"]
	set info_prodVersion   [ttk::spinbox $mainframe.prodVersion -width 15]
	
	grid config $info_prodVersion_l		-row  9 -column 0 -sticky e -ipadx 10
	grid config $info_prodVersion		-row  9 -column 1 -sticky w -columnspan 3
	
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

# Extra Files
set extraFiles_l [ttk::label $mainframe.extraFiles_l -text "Extra Files"]
set extraFiles   [listbox $mainframe.extraFiles -width 90 -selectmode multiple -listvariable extraFilesList]
set extraFiles_file [ttk::button $mainframe.extraFiles_adf -text "+File" -command "browseDialog OPEN $extraFiles \"*\" 1"]
set extraFiles_folder [ttk::button $mainframe.extraFiles_adF -text "+Folder" -command "browseDialog FOLDER $extraFiles {} 1"]
set extraFiles_remove [ttk::button $mainframe.extraFiles_adX -text "-Remove" -command removeExtra]
set extraFiles_note1 [ttk::label $mainframe.extraFiles_note1 -text "The above files & folders will all be placed in the root directory of the virtual FS"]
set extraFiles_note2 [ttk::label $mainframe.extraFiles_note2 -text "(To access these files, use the starkit::topdir variable in your scripts when it is compiled)"]

grid config $extraFiles_l				-row 15 -column 0 -sticky w
grid config $extraFiles					-row 16 -column 0 -sticky w -columnspan 3 -rowspan 6
grid config $extraFiles_file			-row 16 -column 5 -sticky w
grid config $extraFiles_folder			-row 17 -column 5 -sticky w
grid config $extraFiles_remove			-row 18 -column 5 -sticky w
grid config $extraFiles_note1			-row 23 -column 0 -sticky w -columnspan 3 -padx 24
grid config $extraFiles_note2			-row 24 -column 0 -sticky w -columnspan 3 -padx 24


# Buttons
set about [ttk::button $mainframe.about -text "About" -command about]
set build [ttk::button $mainframe.build -text "Build" -command build]
grid config $about						-row 25 -column 5 -sticky e -pady 10
grid config $build						-row 25 -column 4 -sticky e -pady 10


pack $mainframe -padx 20 -pady 15
wm resizable . 0 0



proc browseDialog {openOrSaveOrFolder widget extension multifile} {
	global lastBrowseDir
	global extraFiles
	global extraFilesList
	
	set types_ [list {Tcl Scripts} .$extension]
	set types [list $types_]

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
}

proc removeExtra {} {
	global extraFiles
	global extraFilesList
	set I [lreverse [$extraFiles curselection]]
	foreach i $I {
		set extraFilesList [lreplace $extraFilesList $i $i]
	}
}