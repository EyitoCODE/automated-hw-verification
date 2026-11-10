# Run from any working directory and propagate every tool/check failure.
set root [file dirname [file dirname [file normalize [info script]]]]
cd $root
file mkdir reports
set sim_error ""
if {[catch {exec iverilog -g2012 -o reports/sim.vvp src/rtl/opto_filter.v src/tb/opto_filter_tb.v} error]} {
    puts stderr "Compilation failed: $error"
    exit 1
}
if {[catch {exec vvp reports/sim.vvp > reports/sim.log 2>@1} error]} {
    set sim_error $error
}
# Generate a diagnostic report even when the testbench fails.
if {[catch {exec perl scripts/parse_results.pl 2>@1} report]} {
    puts stderr $report
    if {$sim_error ne ""} { puts stderr $sim_error }
    exit 1
}
puts $report
if {$sim_error ne ""} {
    puts stderr "Simulation failed: $sim_error"
    exit 1
}
puts "Verification passed. Report: [file join $root reports index.html]"
