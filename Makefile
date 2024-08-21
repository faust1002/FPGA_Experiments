DESIGN = test
DEVICE = xc7a100tcsg324-1
BUILD_DIR = ./build_artifacts
SRC_DIR = ./src
TB_DIR = ./tb
XDC_DIR = ./xdc
XDC_FILE = Nexys-A7-100T-Master.xdc
EDIF_FILE = ${DESIGN}.edf

.PHONY: all
all: bitstream

.PHONY: bitstream
bitstream: ${BUILD_DIR}/${DESIGN}.bit

.PHONY: synth
synth: ${BUILD_DIR}/${EDIF_FILE}

${BUILD_DIR}/${DESIGN}.bit: ./run_vivado_bitstream.tcl ${BUILD_DIR}/${EDIF_FILE} ${XDC_DIR}/${XDC_FILE}
	vivado -mode batch -source run_vivado_bitstream.tcl -tclargs ${DESIGN} ${DEVICE} ${EDIF_FILE} ${XDC_FILE} ${XDC_DIR} ${BUILD_DIR}

${BUILD_DIR}/${EDIF_FILE}: ./run_vivado_synth.tcl
	vivado -mode batch -source run_vivado_synth.tcl -tclargs ${DESIGN} ${DEVICE} ${EDIF_FILE} ${SRC_DIR} ${BUILD_DIR}

.PHONY: clean
clean:
	rm -rf *.jou *.log *.tar.gz *.vcd clockInfo.txt ${BUILD_DIR}

.PHONY: tar
tar:
	tar -zcvf ${DESIGN}.tar.gz *.jou *.log *.tcl *.vcd clockInfo.txt Makefile ${BUILD_DIR}

${BUILD_DIR}/testbench: ${SRC_DIR}/*.v ${TB_DIR}/*.v
	iverilog -Dtestbench -Wall $^ -o $@

.PHONY: sim
sim:
	./test_runner.py
