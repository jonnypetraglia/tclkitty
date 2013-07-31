source header.tcl
source gui.tcl



proc build {} {
	global APP_DIR
	global PATH_tclkit
	global PATH_sdx
	global mainfile
	global outputfile
	global extraFilesList
	global cleanupList
	global ExeExtension
	
	################### Get string things ###################
	# Get info from gui
	set Vmainfile [$mainfile get]
	set Voutputfile [$outputfile get]
	
	set a [expr [string length [file dirname $Vmainfile]] +1]
	set b [expr [string length $Vmainfile] - [string length [file extension $Vmainfile]] -1]
	set filenameMinusExtension [string range $Vmainfile $a $b]
	set kitfile $filenameMinusExtension.kit	
	set vfsfolder $filenameMinusExtension.vfs
	set outputfile $filenameMinusExtension$ExeExtension
	set tempfolder "TMP_BUILD"
	
	# CD to dir
	cd "[file dirname $Vmainfile]"
	
	
	#### Clean ####
	file delete -force -- $vfsfolder
	file delete -force -- $kitfile
	file delete -force -- $outputfile
	file delete -force -- $tempfolder
	
	################### Create .kit ###################
	set pid [exec "$APP_DIR/resources/$PATH_tclkit" "$APP_DIR/resources/$PATH_sdx" qwrap "$Vmainfile" "&"]
	if {![waitForFile $kitfile]} {
		cleanup "ERROR: kitfile"
		kill $pid
		return
	}
	kill $pid
	lappend cleanupList $kitfile
	
	################### Unwrap .kit ###################
	set pid [exec "$APP_DIR/resources/$PATH_tclkit" "$APP_DIR/resources/$PATH_sdx" unwrap "$kitfile" "&"]
	if {![waitForFile $vfsfolder]} {
		cleanup "ERROR: unwrap"
		kill $pid
		return
	}
	kill $pid
	lappend cleanupList $vfsfolder
	
	################### Copy extra files into $filenameMinusExtension.vfs ###################

	foreach f $extraFilesList {
		file copy $f $vfsfolder\.
		if {[file exists $f]} {
			cleanup "ERROR: xtra files:   $f"
			return
		}
	}

	################### Re-wrap ###################

	# Create copy of tclkit executable
	set tclCopy "$tempfolder/$PATH_tclkit"
	file mkdir $tempfolder
	file copy -force -- "$APP_DIR/resources/$PATH_tclkit" "$tclCopy"
	lappend cleanupList "$tempfolder"
	if {![file exists $tclCopy]} {
		cleanup "ERROR: tempdir  $tclCopy"
		return
	}
	
	set pid [exec "$APP_DIR/resources/$PATH_tclkit" "$APP_DIR/resources/$PATH_sdx" wrap "$outputfile" "-runtime" "$tclCopy" "&"]
	if {![waitForFile $outputfile]} {
		cleanup "ERROR: re-wrap"
		kill $pid
		return
	}
	kill $pid
	while {[file exists $tclCopy] && [catch {[file delete -force -- $tclCopy]}]} {
		puts "Waiting... $pid    $tclCopy"
	}
	
	#cleanup "SUCCESS!    $outputfile"
}

proc cleanup {reason} {
	global cleanupList
	puts $reason
	foreach f $cleanupList {
		file delete -force -- $f
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

