proc export {} {
    global mainfile
    global outputfolder
    global iconfile
    
    global extraFilesList
    global pkgFilesList
    
    global info_fileVersion
    global info_fileDesc
    global info_prodVersion
    global info_prodName
    global info_origName
    global info_company
    global info_copyright
    
    global createMacApp
    global info_prodVersion
    global info_fileVersion
    global macVersion
    global macVersionrel
    global info_id
    global info_name
    global macInfoEnabled
    
    
    ## Get Output file ##
    set outputfile [tk_getSaveFile -filetypes {{"tclkitty file" {"tclkitty"}}}]
    if {$outputfile == ""} {
        return
    }
    if {![regexp ".tclkitty$" $outputfile]} {
        set outputfile "$outputfile.tclkitty"
    }
    
    ## Open writable file ##
    set ini [::ini::open $outputfile "w"]
    
    #### Get info from gui & write it ####
    ::ini::set $ini "Main" "mainfile" [$mainfile get]
    ::ini::set $ini "Main" "outputfolder" [$outputfolder get]
    ::ini::set $ini "Main" "iconfile" [$iconfile get]
    
    
    ##### Windows #####
    if {$::PLATFORM == $::PLATFORM_WIN} {
        for {set i 1} {$i<=4} {incr i} {
            ::ini::set $ini "Windows" "info_fileVersion$i" [$info_fileVersion($i) get]
            ::ini::set $ini "Windows" "info_prodVersion$i" [$info_prodVersion($i) get]
        }
        ::ini::set $ini "Windows" "info_fileDesc"  [$info_fileDesc get]
        ::ini::set $ini "Windows" "info_prodName"  [$info_prodName get]
        ::ini::set $ini "Windows" "info_origName"  [$info_origName get]
        ::ini::set $ini "Windows" "info_company"   [$info_company get]
        ::ini::set $ini "Windows" "info_copyright" [$info_copyright get]
    }
    
    ##### Mac #####
    if {$::PLATFORM == $::PLATFORM_MAC} {
        # TODO
    }
    
    ##### Packages #####
    for {set i 0} {$i<[llength $pkgFilesList]} {incr i} {
        ::ini::set $ini "Packages" "pkgFiles$i" [lindex $pkgFilesList $i]
    }
    
    ##### Files #####
    for {set i 0} {$i<[llength $extraFilesList]} {incr i} {
        ::ini::set $ini "Files" "extraFiles$i" [lindex $extraFilesList $i]
    }
    
    ::ini::commit $ini
    ::ini::close $ini
}

proc import {} {
    global mainfile
    global outputfolder
    global iconfile
    
    global extraFilesList
    global pkgFilesList
    
    global info_fileVersion
    global info_fileDesc
    global info_prodVersion
    global info_prodName
    global info_origName
    global info_company
    global info_copyright
    
    global createMacApp
    global info_prodVersion
    global info_fileVersion
    global macVersion
    global macVersionrel
    global info_id
    global info_name
    global macInfoEnabled
    
    
    ## Get Output file ##
    set inputfile [tk_getOpenFile -filetypes {{"tclkitty file" {"tclkitty"}}}]
    if {$inputfile == ""} {
        return
    }
    
    ## Open writable file ##
    set ini [::ini::open $inputfile "r"]
    
    #### Save settings to GUI ####
    $mainfile insert 0     [::ini::value $ini "Main" "mainfile"]
    $outputfolder insert 0 [::ini::value $ini "Main" "outputfolder"]
    $iconfile insert 0     [::ini::value $ini "Main" "iconfile"]
    
    ##### Windows #####
    if {$::PLATFORM == $::PLATFORM_WIN} {
        for {set i 1} {$i<=4} {incr i} {
            $info_fileVersion($i) set [::ini::value $ini "Windows" "info_fileVersion$i" 0]
            $info_prodVersion($i) set [::ini::value $ini "Windows" "info_prodVersion$i" 0]
        }
        $info_fileDesc  insert 0 [::ini::value $ini "Windows" "info_fileDesc"]
        $info_prodName  insert 0 [::ini::value $ini "Windows" "info_prodName"]
        $info_origName  insert 0 [::ini::value $ini "Windows" "info_origName"]
        $info_company   insert 0 [::ini::value $ini "Windows" "info_company"]
        $info_copyright insert 0 [::ini::value $ini "Windows" "info_copyright"]
    }
    
    ##### Mac #####
    if {$::PLATFORM == $::PLATFORM_MAC} {
        # TODO
    }
    
    ##### Packages #####
    set i 0
    while {[::ini::exists $ini "Packages" "pkgFiles$i"]} {
        lappend pkgFilesList [::ini::value $ini "Packages" "pkgFiles$i"]
        incr i
    }
    
    set i 0
    ##### Files #####
    for {set i 0} {$i<[llength $extraFilesList]} {incr i} {
        lappend extraFilesList [::ini::value $ini "Files" "extraFiles$i"]
        incr i
    }
}