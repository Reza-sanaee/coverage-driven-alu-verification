set script_dir [pwd]
if {![file exists [file join $script_dir .. hvl class_pkg.sv]]} {error "Start Questa in the code/sim directory"}
cd $script_dir
set databases [glob -nocomplain [file join $script_dir results * *.ucdb]]
if {[llength $databases]==0} {error "Run simulations before merging coverage"}
set report_dir [file join $script_dir results combined]
file mkdir $report_dir
xml2ucdb -format Excel test_plan.xml [file join $report_dir test_plan.ucdb]
vcover merge -testassociated -out [file join $report_dir merged.ucdb] [file join $report_dir test_plan.ucdb] {*}$databases
vcover report -html [file join $report_dir merged.ucdb] -details -annotate -testdetails -showexcluded -output [file join $report_dir html]
vcover ranktest -iterative -cvg -stats=none -rankfile [file join $report_dir vsim.rank] -logfile [file join $report_dir ranked_tests.txt] {*}$databases
