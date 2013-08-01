variable APP_DIR
if [info exists starkit::topdir] {
	set APP_DIR $starkit::topdir
} else {
	set APP_DIR "[file normalize [pwd]/[file dirname [info script]]]"
}

source $APP_DIR/header.tcl
source $APP_DIR/gui.tcl



proc build {} {
	global APP_DIR
	global PATH_tclkit
	global PATH_tclcompiler
	global PATH_sdx
	
	global mainfile
	global outputfolder
	global iconfile
	
	global extraFilesList
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


	#### Clean ####
	file delete -force -- $vfsfolder
	file delete -force -- $kitfile
	file delete -force -- $outputexe
	file delete -force -- $tempfolder
	
	################### Create .kit ###################
	puts "create"
	exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" qwrap "$Vmainfile"
	puts "create2"
	#if {![waitForFile $kitfile]} {
		#cleanup "ERROR: kitfile"
		#kill $pid
		#return
	#}
	#kill $pid
	lappend cleanupList $kitfile
	
	################### Unwrap .kit ###################
	set pid [exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" unwrap "$kitfile"]
	#if {![waitForFile $vfsfolder]} {
		#cleanup "ERROR: unwrap"
		#kill $pid
		#return
	#}
	#kill $pid
	lappend cleanupList $vfsfolder

	################### Copy extra files into $filenameMinusExtension.vfs ###################

	foreach f $extraFilesList {
		#set newfile "$vfsfolder/lib/app-$filenameMinusExtension/[getFilename $f]"
		set newfile "$vfsfolder/[getFilename $f]"
		file copy $f $newfile
		if {![file exists $newfile]} {
			cleanup "ERROR: xtra files:   $f"
			return
		}
	}

	################### Re-wrap ###################

	# Create copy of tclkit executable
	#set tclCopy "$tempfolder/$PATH_tclkit"
	#file mkdir $tempfolder
	#file copy -force -- "$APP_DIR/resources/$PATH_tclkit" "$tclCopy"
	#lappend cleanupList "$tempfolder"
	#if {![file exists $tclCopy]} {
		#cleanup "ERROR: tempdir  $tclCopy"
		#return
	#}
	
	set pid [exec "$APP_DIR/resources/$PATH_tclcompiler" "$APP_DIR/resources/$PATH_sdx" wrap "$outputexe" "-runtime" "$APP_DIR/resources/$PATH_tclkit"]
	#if {![waitForFile $outputexe]} {
		#cleanup "ERROR: re-wrap"
		#kill $pid
		#return
	#}
	# Wait a second
	#set derp 0
	#after 1000 { set derp 1}
	#vwait derp
	
	#while {[file exists $outputexe.tmp]} {
	#	puts "$outputexe.tmp"
	#}
	#kill $pid
	#while {[file exists $tclCopy] && [catch {[file delete -force -- $tclCopy]}]} {
	#	puts "Waiting... $pid    $tclCopy"
	#}
	
	cleanup "SUCCESS!    $outputexe"
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

proc cleanup {reason} {
	global cleanupList
	puts $reason
	foreach f $cleanupList {
		puts "file delete -force -- $f"
	}
}

proc about {} {
	
}

proc kill {pid} {
	if {$::PLATFORM == $::PLATFORM_WIN} {
		exec [auto_execok taskkill] /F /PID $pid
	} else {
		exec kill -KILL $pid
		# Or TERM
	}
}

# Returns 1 if the file was created, 0 otherwise
proc waitForFile {f} {
	set i 0
	while {![file exists $f] && $i<100000} {
		incr i
	}
	if {[file exists $f]} {
		return 1
	}
	return 0
}

