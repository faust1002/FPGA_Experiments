PROJECT_NAME     = fir
TOP_LEVEL_MODULE = top
DEVICE           = xc7a100tcsg324-1

OUTPUT_DIR = ./output
PROJ_DIR   = $(OUTPUT_DIR)/$(PROJECT_NAME)
RUNS_DIR   = $(OUTPUT_DIR)/runs
SIM_DIR    = $(OUTPUT_DIR)/sim
SCRIPT_DIR = ./scripts
RTL_DIR    = ./rtl
TB_DIR     = ./tb

RTL_SOURCES = $(wildcard $(RTL_DIR)/*.v $(RTL_DIR)/*.sv)
VIVADO_ENV  = LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1
VIVADO      = $(VIVADO_ENV) vivado -mode batch -nolog -nojournal

###############################################################################

.PHONY: all
all: synth

###############################################################################

.PHONY: create
create: $(PROJ_DIR)/$(PROJECT_NAME).xpr
$(PROJ_DIR)/$(PROJECT_NAME).xpr: $(SCRIPT_DIR)/create_project.tcl
	$(VIVADO) -source $(SCRIPT_DIR)/create_project.tcl -tclargs $(PROJECT_NAME) $(DEVICE) $(TOP_LEVEL_MODULE) $(PROJ_DIR) $(RTL_SOURCES)
	@echo "$(RTL_SOURCES)" > $(PROJ_DIR)/.files_manifest

###############################################################################

$(PROJ_DIR)/.synth_done: $(PROJ_DIR)/$(PROJECT_NAME).xpr $(SCRIPT_DIR)/run_synth.tcl $(RTL_SOURCES)
	$(VIVADO) -source $(SCRIPT_DIR)/run_synth.tcl -tclargs $(PROJECT_NAME) $(PROJ_DIR) $(RUNS_DIR)
	@touch $@

.PHONY: synth
synth: $(PROJ_DIR)/.synth_done

###############################################################################

.PHONY: update
update:
	@if ! echo "$(RTL_SOURCES)" | cmp -s - $(PROJ_DIR)/.files_manifest 2>/dev/null; then \
		echo "$(VIVADO) -source $(SCRIPT_DIR)/update_project.tcl -tclargs $(PROJECT_NAME) $(PROJ_DIR) $(RTL_SOURCES)"; \
		$(VIVADO) -source $(SCRIPT_DIR)/update_project.tcl -tclargs $(PROJECT_NAME) $(PROJ_DIR) $(RTL_SOURCES); \
		echo "$(RTL_SOURCES)" > $(PROJ_DIR)/.files_manifest; \
	else \
		echo "Nothing to be done for 'update'"; \
	fi

###############################################################################

.PHONY: sim
sim:
	SIM_DIR=$(SIM_DIR) PYTHONPATH=$(TB_DIR) ./test_runner.py

###############################################################################

.PHONY: clean
clean:
	rm -rf .Xil *.jou *.log $(OUTPUT_DIR)/*

###############################################################################

.PHONY: help
help:
	@echo "Targets:"
	@echo "  all    - Run synthesis (default)"
	@echo "  create - Create Vivado project"
	@echo "  update - Sync RTL file additions/removals into existing project"
	@echo "  synth  - Run synthesis"
	@echo "  sim    - Run simulation"
	@echo "  clean  - Remove build artifacts"
