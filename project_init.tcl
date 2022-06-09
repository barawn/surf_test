# utility function
proc get_repo_dir {} {
    set projdir [get_property DIRECTORY [current_project]]
    set projdirlist [ file split $projdir ]
    set basedirlist [ lreplace $projdirlist end end ]
    return [ file join {*}$basedirlist ]
}

set include_dir [file join [get_repo_dir] "include"]
set_property include_dirs [list $include_dir] [current_fileset]

