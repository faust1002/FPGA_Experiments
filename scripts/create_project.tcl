set PROJECT_NAME    [lindex $argv 0]
set DEVICE          [lindex $argv 1]
set TOP_MODULE_NAME [lindex $argv 2]
set PROJ_DIR        [lindex $argv 3]
set RTL_SOURCES     [lrange $argv 4 end]

create_project -force -part $DEVICE $PROJECT_NAME $PROJ_DIR
add_files -fileset sources_1 $RTL_SOURCES
set_property top $TOP_MODULE_NAME [get_filesets sources_1]
update_compile_order -fileset sources_1

close_project
