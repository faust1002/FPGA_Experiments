set PROJECT_NAME [lindex $argv 0]
set DEVICE [lindex $argv 1]
set PROJ_DIR [lindex $argv 2]
set RTL_DIR [lindex $argv 3]

create_project -force -part ${DEVICE} ${PROJECT_NAME} ${PROJ_DIR}
add_files -fileset sources_1  [glob ${RTL_DIR}/*.v]
