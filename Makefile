SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(shell pwd)
SCRIPTS                 := $(ABS_TOP)/scripts
VIVADO                  ?= vivado
VIVADO_OPTS             ?= -nolog -nojournal -mode batch
FPGA_PART               ?= xc7z020clg400-2
RTL                     += $(shell find $(ABS_TOP)/src -type f -name "*.sv")
CONSTRAINTS             += $(shell find $(ABS_TOP)/src -type f -name "*.xdc")
MIFS                    += $(shell find $(ABS_TOP)/src -type f -name "*.bin" -o -name "*.hex")
TOP                     ?= top

SIM_RTL                 := $(shell find $(ABS_TOP)/sim -type f -name "*.sv")
SIM_TARGETS             := $(shell realpath --relative-to $(ABS_TOP) $(SIM_RTL))
IVERILOG                := iverilog
IVERILOG_OPTS           := -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale
IVERILOG_TARGETS        := $(SIM_TARGETS:%.sv=%.fst)
VVP                     := vvp

all: build/impl/$(TOP).bit

sim/%.tbi: sim/%.sv $(RTL)
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o $*.tbi $*.sv $(RTL) $(SIM_MODELS)

sim/%.fst: sim/%.tbi
	cd sim && $(VVP) $*.tbi -fst |& tee $*.log

build/target.tcl: $(RTL) $(CONSTRAINTS)
	@mkdir -p build
	@truncate -s 0 $@
	@echo "set ABS_TOP                        $(ABS_TOP)"    >> $@
	@echo "set TOP                            $(TOP)"    >> $@
	@echo "set FPGA_PART                      $(FPGA_PART)"  >> $@
	@echo "set_param general.maxThreads       4"    >> $@
	@echo "set_param general.maxBackupLogs    0"    >> $@
	@echo -n "set RTL { " >> $@
	@FLIST="$(RTL)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	@echo "}" >> $@
	@echo -n "set CONSTRAINTS { " >> $@
	@FLIST="$(CONSTRAINTS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	@echo "}" >> $@
	@echo -n "set MIFS { " >> $@
	@FLIST="$(MIFS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	@echo "}" >> $@

setup: build/target.tcl

elaborate: build/target.tcl $(SCRIPTS)/elaborate.tcl
	mkdir -p ./build
	cd ./build && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/elaborate.tcl |& tee elaborate.log

build/synth/$(TOP).dcp: build/target.tcl $(SCRIPTS)/synth.tcl
	mkdir -p ./build/synth/
	cd ./build/synth/ && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/synth.tcl |& tee synth.log

synth: build/synth/$(TOP).dcp

build/impl/$(TOP).bit: build/synth/$(TOP).dcp $(SCRIPTS)/impl.tcl
	mkdir -p ./build/impl/
	cd ./build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/impl.tcl |& tee impl.log

impl: build/impl/$(TOP).bit
all: build/impl/$(TOP).bit

program: build/impl/$(TOP).bit $(SCRIPTS)/program.tcl
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

program-force:
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

vivado: build
	cd build && nohup $(VIVADO) </dev/null >/dev/null 2>&1 &

lint:
	verilator --lint-only --top-module $(TOP) $(RTL)

clean:
	rm -rf ./build $(junk) *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.vcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out

.PHONY: setup synth impl program program-force vivado all clean %.tb
.PRECIOUS: sim/%.tb sim/%.tbi sim/%.fst sim/%.vpd

