PZTB_HOME	?= $(shell git rev-parse --show-toplevel)

PZVIP_HOME	?= $(PZTB_HOME)/pzvip
export PZVIP_HOME
export PA_CUSTOM_VIP_PATH=$(PZVIP_HOME)/verdi_pa_extensions

TUE_HOME	?= $(PZTB_HOME)/tue
export TUE_HOME

FILE_LISTS	+= $(TUE_HOME)/compile.f
FILE_LISTS	+= $(PZVIP_HOME)/pzvip_common/compile.f
FILE_LISTS	+= $(PZVIP_HOME)/pzvip_corebus/compile.f
FILE_LISTS	+= $(PZVIP_HOME)/pzvip_corebus/sample/env/compile.f

RANDOM_SEED	?= auto
GUI ?= off
DUMP ?= off
ENABLE_PA_WRITER ?= off

VCS_ARGS	+= -full64
VCS_ARGS	+= -sverilog
VCS_ARGS	+= -ntb_opts uvm
VCS_ARGS	+= -timescale=1ns/1ps
VCS_ARGS	+= -l compile.log
VCS_ARGS	+= $(addprefix -f , $(FILE_LISTS))

SIMV_ARGS	+= -l simv.log
SIMV_ARGS	+= -f test.f
SIMV_ARGS += +vcs+lic+wait

ifeq ($(strip $(RANDOM_SEED)), auto)
	SIMV_ARGS	+= +ntb_random_seed_automatic
else
	SIMV_ARGS	+= +ntb_random_seed=$(RANDOM_SEED)
endif

ifeq ($(strip $(GUI)), dve)
	VCS_ARGS	+= -debug_access+all
	VCS_ARGS	+= +vcs+vcdpluson
	SIMV_ARGS	+= -gui=dve
endif
ifeq ($(strip $(GUI)), verdi)
	VCS_ARGS	+= -debug_access+all
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
	SIMV_ARGS	+= -gui=verdi
endif

ifeq ($(strip $(DUMP)), fsdb)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
	SIMV_ARGS	+= +fsdbfile+out.fsdb
endif
ifeq ($(strip $(DUMP)), vpd)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= +vcs+vcdpluson
	SIMV_ARGS	+= -vpd_file out.vpd
endif

ifeq ($(strip $(ENABLE_PA_WRITER)), on)
	VCS_ARGS	+= -debug_access+r
	VCS_ARGS	+= +incdir+$(VERDI_HOME)/share/pa_writer/sv/src
	VCS_ARGS	+= +define+_PZ_PZVIP_ENABLE_PA_WRITER_
endif

TESTS	+= csr_default
TESTS	+= csr_delay
TESTS	+= memory_l_default
TESTS	+= memory_l_delay
TESTS	+= memory_h_default
TESTS	+= memory_h_delay
TESTS	+= memory_h_response_interleaving

CLEAN	+= *.log
CLEAN	+= simv*
CLEAN	+= csrc
CLEAN	+= *.h

CLEAN_ALL	+= *.log
CLEAN_ALL	+= *.rpt
CLEAN_ALL	+= *.vpd
CLEAN_ALL	+= *.fsdb
CLEAN_ALL	+= *.key
CLEAN_ALL	+= *.rc
CLEAN_ALL	+= DVEfiles
CLEAN_ALL	+= .inter.vpd.uvm
CLEAN_ALL	+= verdiLog
CLEAN_ALL	+= verdi_config_file
CLEAN_ALL	+= novas.*

.PHONY: all $(TESTS) sim_vcs compile_vcs clean clean_all

all: $(TESTS)

$(TESTS):
	$(MAKE) sim_vcs TEST=$@

sim_vcs:
	[ -f simv ] || $(MAKE) compile_vcs
	cd $(TEST); ../simv $(SIMV_ARGS)

compile_vcs:
	vcs $(VCS_ARGS)

clean:
	rm -rf $(CLEAN)

clean_all:
	$(MAKE) clean
	rm -rf $(CLEAN_ALL)
	rm -rf $(addprefix */,$(CLEAN_ALL))
