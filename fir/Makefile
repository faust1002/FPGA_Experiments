PROJECT_NAME = fir
DESIGN       = top
DEVICE       = xc7a100tcsg324-1

OUTPUT_DIR = ./output
PROJ_DIR   = ${OUTPUT_DIR}/${PROJECT_NAME}
RUNS_DIR   = ${OUTPUT_DIR}/runs
SIM_DIR = ${OUTPUT_DIR}/sim
SCRIPT_DIR = ./scripts
RTL_DIR    = ./rtl
TB_DIR     = ./tb

VIVADO = LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 vivado -mode batch -nolog -nojournal

.PHONY: all
all: synth

${RUNS_DIR}/.synth_done: ${PROJ_DIR}/${PROJECT_NAME}.xpr ${SCRIPT_DIR}/run_synth.tcl ${RTL_DIR}/*.v
	${VIVADO} -source ${SCRIPT_DIR}/run_synth.tcl -tclargs ${PROJECT_NAME} ${PROJ_DIR} ${RUNS_DIR}
	touch $@

.PHONY: synth
synth: ${RUNS_DIR}/.synth_done

.PHONY: create
create: ${PROJ_DIR}/${PROJECT_NAME}.xpr
${PROJ_DIR}/${PROJECT_NAME}.xpr: ${SCRIPT_DIR}/create_project.tcl ${RTL_DIR}/*.v
	${VIVADO} -source ${SCRIPT_DIR}/create_project.tcl -tclargs ${PROJECT_NAME} ${DEVICE} ${PROJ_DIR} ${RTL_DIR}

.PHONY: sim
sim:
	SIM_DIR=${SIM_DIR} PYTHONPATH=${TB_DIR} ./test_runner.py

.PHONY: clean
clean:
	rm -rf .Xil *.jou *.log ${OUTPUT_DIR}/*

