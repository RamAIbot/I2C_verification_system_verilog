GEN_TRANS_TYPE ?= wb_transaction_base
I2C_GEN_TRANS_TYPE ?= i2c_transaction_base
TEST_SEED ?= 12345
TEST_NAME ?= i2cmb_test_base

export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript

comp_I2C_MB:
	vcom -cover bces ../rtl/iicmb_int_pkg.vhd
	vcom -cover bces ../rtl/iicmb_pkg.vhd
	vcom -cover bcesf ../rtl/mbyte.vhd
	vcom -cover bcesf ../rtl/mbit.vhd
	vcom -cover bces ../rtl/bus_state.vhd
	vcom -cover bces ../rtl/filter.vhd
	vcom -cover bces ../rtl/conditioner.vhd
	vcom -cover bces ../rtl/conditioner_mux.vhd
	vcom -cover bces ../rtl/iicmb_m.vhd
	vcom -cover bces ../rtl/regblock.vhd
	vcom -cover bces ../rtl/wishbone.vhd
	vcom -cover bces ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

run_cli:
	vsim  -c -sv_seed 12345 -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(TEST_NAME); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb;quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +I2C_GEN_TRANS_TYPE=$(I2C_GEN_TRANS_TYPE) optimized_debug_top_tb -coverage

run_gui:
	vsim  -sv_seed 12345 -do "run 0;do wave.do;run -a" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +I2C_GEN_TRANS_TYPE=$(I2C_GEN_TRANS_TYPE) optimized_debug_top_tb

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +I2C_GEN_TRANS_TYPE=$(I2C_GEN_TRANS_TYPE) optimized_debug_top_tb 

debug: clean compile optimize run_gui

cli: clean compile optimize run_cli

convert_testplan:
	xml2ucdb -format Excel ./test_plan_layered_testbench.xml ./test_plan_layered_testbench.ucdb
	add testbrowser ./*.ucdb
merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 
	#coverage open ./sim_and_testplan_merged.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

#merge_coverage_with_test_plan:convert_testplan merge_coverage report_coverage

merge_coverage_with_test_plan:
	vsim -do "load_ucdbs_and_merge_with_test_plan.do"
	