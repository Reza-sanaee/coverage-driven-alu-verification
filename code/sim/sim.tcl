set script_dir [pwd]
if {![file exists [file join $script_dir .. hvl class_pkg.sv]]} {error "Start Questa in the code/sim directory"}
set project_root [file normalize [file join $script_dir ..]]
cd $script_dir
if {![info exists test_name]} {set test_name test_high}
if {![info exists sv_seed]} {set sv_seed 42}
if {$test_name ni {random_test test_mid test_high test_mix}} {error "Unknown test name"}
if {![string is integer -strict $sv_seed]} {error "Seed must be an integer"}
set run_dir [file join $script_dir results ${test_name}_${sv_seed}]
file mkdir $run_dir
transcript file [file join $run_dir transcript.log]
set work_dir [file join $run_dir work]
if {![file exists $work_dir]} {vlib $work_dir}
vmap -c
vmap work $work_dir
set selection ""
switch $test_name {
    test_mid {set selection +define+TEST_MID}
    test_mix {set selection +define+TEST_MIX}
    random_test {set selection +define+TEST_RANDOM}
}
vlog -sv -work work [file join $project_root hvl parameter_packages parameters.sv]
vlog -sv -work work [file join $project_root hvl interface_packages alu_in_pkg ALU_in_if.sv]
vlog -sv -work work [file join $project_root hvl interface_packages alu_out_pkg ALU_out_if.sv]
vlog -sv -cover fsb -work work [file join $project_root hdl alu_multi_cycle.sv]
vlog -sv -work work +incdir+$project_root/hvl [file join $project_root hvl class_pkg.sv]
vlog -sv -work work {*}[glob [file join $project_root hvl tests *.sv]]
if {$selection ne ""} {
    vlog -sv -work work $selection [file join $project_root hvl top.sv]
} else {
    vlog -sv -work work [file join $project_root hvl top.sv]
}
vsim -sv_seed $sv_seed -coverage -voptargs=+acc work.top
onfinish stop
coverage attribute -name TESTNAME -value ${test_name}${sv_seed}
run -all
coverage save [file join $run_dir ${test_name}_${sv_seed}.ucdb]
quit -f
