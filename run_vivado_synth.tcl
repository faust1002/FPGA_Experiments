set DESIGN [lindex $argv 0]
set DEVICE [lindex $argv 1]
set EDIF_FILE [lindex $argv 2]
set SRC_DIR [lindex $argv 3]
set BUILD_DIR [lindex $argv 4]

read_verilog [ glob ${SRC_DIR}/*.v ]

synth_design -top ${DESIGN} -part ${DEVICE}
write_checkpoint -force ${BUILD_DIR}/${DESIGN}_post_synth.dcp
write_edif -force ${BUILD_DIR}/${EDIF_FILE}

exit
