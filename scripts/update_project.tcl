set PROJECT_NAME [lindex $argv 0]
set PROJ_DIR     [lindex $argv 1]
set RTL_SOURCES  [lrange $argv 2 end]

set XPR_FILE $PROJ_DIR/$PROJECT_NAME.xpr

open_project $XPR_FILE

set existing_files     [get_files -of_objects [get_filesets sources_1]]
set normalized_sources [lmap src $RTL_SOURCES {file normalize $src}]

foreach src $RTL_SOURCES {
    set abs_src [file normalize $src]
    if {$abs_src ni $existing_files} {
        puts "Adding: $abs_src"
        add_files -fileset sources_1 $src
    }
}

foreach existing $existing_files {
    if {$existing ni $normalized_sources} {
        puts "Removing: $existing"
        remove_files -fileset sources_1 $existing
    }
}

update_compile_order -fileset sources_1

close_project
