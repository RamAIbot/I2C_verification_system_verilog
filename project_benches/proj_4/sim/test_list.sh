rm -rf covhtmlreport
rm -rf work
rm -f sim_and_testplan_merged.ucdb
rm -f test_plan_layered_testbench.ucdb
rm -f wb_transaction_base.12344.ucdb
rm -f wb_transaction_base.12345.ucdb



make cli_base

make cli_random

make merge_coverage_with_test_plan