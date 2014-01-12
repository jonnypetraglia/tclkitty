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
    global info_name
    global macVersion
    global macVersionrel
    global info_id
    global info_region
    global info_dict
    global macInfoEnabled

    
    ## Get Output file ##
    set outputfile [tk_getSaveFile -filetypes {{"tclkitty file" {".tclkitty"}}}]
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
    if {[info exists iconfile]} {
        ::ini::set $ini "Main" "iconfile" [$iconfile get]
    }
    
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
    if {$::PLATFORM == $::PLATFORM_MAC && $createMacApp} {
        ::ini::set $ini "Mac" "info_name" [$info_name get]
        for {set i 1} {$i<=3} {incr i} {
            ::ini::set $ini "Mac" "macVersion_$i" [$macVersion($i) get]
            ::ini::set $ini "Mac" "macVersionrel_$i" [$macVersionrel($i) get]
        }
        ::ini::set $ini "Mac" "info_id" [$info_id get]
        ::ini::set $ini "Mac" "info_region" [$info_region get]
        ::ini::set $ini "Mac" "info_dict" [$info_dict get]
        set vals [array names macInfoEnabled]
        foreach val $vals {
            ::ini::set $ini "Mac" "macInfoEnabled_$val" $macInfoEnabled($val)
        }
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
    global info_name
    global macVersion
    global macVersionrel
    global info_id
    global info_region
    global info_dict
    global macInfoEnabled
    
    
    ## Get Output file ##
    set inputfile [tk_getOpenFile -filetypes {{"tclkitty file" {".tclkitty"}}}]
    if {$inputfile == ""} {
        return
    }
    
    ## Open writable file ##
    set ini [::ini::open $inputfile "r"]
    
    #### Save settings to GUI ####
    if {[::ini::exists $ini "Main"]} {
        $mainfile delete 0
        $mainfile insert 0     [::ini::value $ini "Main" "mainfile"]
        $outputfolder delete 0
        $outputfolder insert 0 [::ini::value $ini "Main" "outputfolder"]
        if {[info exists iconfile]} {
            $iconfile delete 0
            $iconfile insert 0     [::ini::value $ini "Main" "iconfile"]
        }
    }
    
    ##### Windows #####
    if {$::PLATFORM == $::PLATFORM_WIN && [::ini::exists $ini "Windows"]} {
        for {set i 1} {$i<=4} {incr i} {
            $info_fileVersion($i) set [::ini::value $ini "Windows" "info_fileVersion$i" 0]
            $info_prodVersion($i) set [::ini::value $ini "Windows" "info_prodVersion$i" 0]
        }
        $info_fileDesc  delete 0
        $info_fileDesc  insert 0 [::ini::value $ini "Windows" "info_fileDesc"]
        $info_prodName  delete 0
        $info_prodName  insert 0 [::ini::value $ini "Windows" "info_prodName"]
        $info_origName  delete 0
        $info_origName  insert 0 [::ini::value $ini "Windows" "info_origName"]
        $info_company   delete 0
        $info_company   insert 0 [::ini::value $ini "Windows" "info_company"]
        $info_copyright delete 0
        $info_copyright insert 0 [::ini::value $ini "Windows" "info_copyright"]
    }
    
    ##### Mac #####
    if {$::PLATFORM == $::PLATFORM_MAC && [::ini::exists $ini "Mac"]} {
        $info_name       delete 0 end
        $info_name       insert 0 [::ini::value $ini "Mac" "info_name"]
        for {set i 1} {$i<=3} {incr i} {
            $macVersion($i) set [::ini::value $ini "Mac" "macVersion_$i"]
            $macVersionrel($i) set [::ini::value $ini "Mac" "macVersionrel_$i"]
        }
        $info_id         delete 0
        $info_id         insert 0 [::ini::value $ini "Mac" "info_id"]
        $info_region     delete 0
        $info_region     insert 0 [::ini::value $ini "Mac" "info_region"]
        $info_dict       delete 0
        $info_dict       insert 0 [::ini::value $ini "Mac" "info_dict"]
        set vals [array names macInfoEnabled]
        foreach val $vals {
            set macInfoEnabled($val) [::ini::value $ini "Mac" "macInfoEnabled_$val"]
        }
    }
    
    ##### Packages #####
    set i 0
    set pkgFilesList [list]
    while {[::ini::exists $ini "Packages" "pkgFiles$i"]} {
        lappend pkgFilesList [::ini::value $ini "Packages" "pkgFiles$i"]
        incr i
    }
    
    ##### Files #####
    set i 0
    set extraFilesList [list]
    while {[::ini::exists $ini "Files" "extraFiles$i"]} {
        lappend extraFilesList [::ini::value $ini "Files" "extraFiles$i"]
        incr i
    }
}
