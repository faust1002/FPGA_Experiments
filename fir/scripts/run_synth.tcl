set PROJECT_NAME [lindex $argv 0]
set PROJ_DIR [lindex $argv 1]
set SYNTH_DIR [lindex $argv 2]

open_project ${PROJ_DIR}/${PROJECT_NAME}.xpr
reset_run synth_1
launch_run -dir ${SYNTH_DIR} synth_1
wait_on_run synth_1
