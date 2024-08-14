set DESIGN [lindex $argv 0]
set DEVICE [lindex $argv 1]
set EDIF_FILE [lindex $argv 2]
set XDC_FILE [lindex $argv 3]
set XDC_DIR [lindex $argv 4]
set BUILD_DIR [lindex $argv 5]

read_edif ${BUILD_DIR}/${EDIF_FILE}
link_design -part ${DEVICE} -edif_top_file ${BUILD_DIR}/${EDIF_FILE}
opt_design
read_xdc ${XDC_DIR}/${XDC_FILE}
write_checkpoint -force ${BUILD_DIR}/${DESIGN}_opt.dcp
report_utilization -file ${BUILD_DIR}/${DESIGN}_utilization_opt.rpt
report_timing_summary -max_paths 10 -nworst 1 -input_pins
report_io -file ${BUILD_DIR}/${DESIGN}_io_opt.rpt
report_clock_interaction -file ${BUILD_DIR}/${DESIGN}_clock_interaction_opt.rpt

place_design
write_checkpoint -force ${BUILD_DIR}/${DESIGN}_place.dcp
route_design
write_checkpoint -force ${BUILD_DIR}/${DESIGN}_route.dcp
report_timing_summary -max_paths 10 -nworst 1 -input_pins
report_drc -file ${BUILD_DIR}/${DESIGN}_drc_route.rpt

write_bitstream -force ${BUILD_DIR}/${DESIGN}.bit
exit
