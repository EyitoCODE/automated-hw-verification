use strict;
use warnings;

my $log_file = "reports/sim.log";
my $report_file = "reports/index.html";

# Open log file for reading
open(my $in_fh, '<', $log_file) or die "Error: Cannot read $log_file: $!";

my $total_tests = 0;
my $passed = 0;
my $failed = 0;
my @table_rows;

# Parse the log file line by line
while (my $line = <$in_fh>) {
    # Regex to find verification lines and capture the pass/fail state
    if ($line =~ /\[VERIFY\] (TEST_CASE_\d+): Input=(.*?) \| Output=(.*?) \| Valid=(\d) \| EXPECTED:.*-> (PASS|FAIL)/) {
        my ($test_id, $in, $out, $valid, $status) = ($1, $2, $3, $4, $5);
        $total_tests++;
        
        my $color = ($status eq 'PASS') ? '#d4edda' : '#f8d7da';
        
        if ($status eq 'PASS') { $passed++; } else { $failed++; }

        push @table_rows, "<tr style='background-color: $color;'>
            <td>$test_id</td><td>$in</td><td>$out</td><td>$valid</td><td><strong>$status</strong></td>
        </tr>";
    }
}
close($in_fh);

# Calculate Yield
my $yield = ($total_tests > 0) ? ($passed / $total_tests) * 100 : 0;

# Generate HTML Report
open(my $out_fh, '>', $report_file) or die "Error: Cannot write to $report_file: $!";

print $out_fh "
<!DOCTYPE html>
<html>
<head>
    <title>Hardware Verification Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; }
        h1 { color: #333; }
        .summary { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;}
        table { width: 100%; border-collapse: collapse; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #0056b3; color: white; }
    </style>
</head>
<body>
    <h1>Automated Hardware Verification Report</h1>
    <div class='summary'>
        <h2>Execution Summary</h2>
        <p><strong>Total Tests:</strong> $total_tests</p>
        <p><strong>Passed:</strong> $passed</p>
        <p><strong>Failed:</strong> $failed</p>
        <p><strong>Yield:</strong> $yield%</p>
    </div>
    <table>
        <tr><th>Test ID</th><th>Input (Hex)</th><th>Output (Hex)</th><th>Valid Flag</th><th>Status</th></tr>
        " . join("\n", @table_rows) . "
    </table>
</body>
</html>
";

close($out_fh);
print "\[PERL\] Success: HTML Report generated at $report_file\n";