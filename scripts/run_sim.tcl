puts "========================================"
puts "  Automated Verification Pipeline v1.0  "
puts "========================================"

# Step 1: Compile the Verilog files
puts "\[TCL\] Compiling RTL and Testbench..."
set compile_status [catch {exec iverilog -o reports/sim.vvp src/rtl/opto_filter.v src/tb/opto_filter_tb.v} result]

if {$compile_status != 0} {
    puts "\[TCL\] Compilation Failed: $result"
    exit 1
}

# Step 2: Run Simulation and pipe to log
puts "\[TCL\] Running Simulation..."
catch {exec vvp reports/sim.vvp > reports/sim.log} result
puts "\[TCL\] Simulation complete. Raw data saved to reports/sim.log"

# Step 3: Trigger Data Extraction
puts "\[TCL\] Triggering Perl Parsing Engine..."
catch {exec perl scripts/parse_results.pl} perl_result
puts $perl_result

puts "========================================"
puts "  Pipeline Execution Complete.          "
puts "========================================"