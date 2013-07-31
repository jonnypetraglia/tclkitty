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
	
	# Get info from gui
	set Vmainfile [$mainfile get]
	set Voutputfile [$outputfile get]


	################### Get string things ###################
	set a [expr [string length [file dirname $Vmainfile]] +1]
	set b [expr [string length $Vmainfile] - [string length [file extension $Vmainfile]] -1]
	set filenameMinusExtension [string range $Vmainfile $a $b]
	set kitfile $filenameMinusExtension.kit	
	set vfsfolder $filenameMinusExtension.vfs
	
	# CD to dir
	cd "[file dirname $Vmainfile]"
	
	
	################### Create .kit ###################
	#TODO Remove kitfile if it already exists
	exec "$APP_DIR/resources/$PATH_tclkit" "$APP_DIR/resources/$PATH_sdx" qwrap "$Vmainfile" "&"
	if {![waitForFile $kitfile]} {
		puts "ERROR: kitfile"
		return
	}
	lappend cleanupList $kitfile
	
	################### Unwrap .kit ###################
	#TODO Remove vfsfolder if it already exists
	exec "$APP_DIR/resources/$PATH_tclkit" "$APP_DIR/resources/$PATH_sdx" unwrap "$kitfile" "&"
	if {![waitForFile $vfsfolder]} {
		puts "ERROR: Unwrap"
		return
	}
	lappend cleanupList $vfsfolder
	
	################### Copy extra files into $filenameMinusExtension.vfs ###################

	foreach f $extraFilesList {
		file copy $f $vfsfolder\.
	}


	# $ tclkit* sdx* wrap {FILENAME}.exe -runtime tclkit.exe
	
	################### Create copy of tclkit executable ###################
	# Create copy of tclkit executable
	#file mkdir "./BUILD_TMP"
	#file copy -force -- "$APP_DIR/resources/$PATH_tclkit" "./BUILD_TMP/$PATH_tclkit"
}

proc cleanup {reason} {
	global cleanupList
}

proc about {} {
	
}

proc waitForFile {f} {
	# TODO: this should not be needed, why doesn't TCLkit exit automatically
	set i 0
	while {![file exists $f] && $i<100000} {
		incr i
	}
	if {[file exists $f]} {
		return 1
	}
	return 0
}

