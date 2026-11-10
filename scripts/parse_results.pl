use strict;
use warnings;
use FindBin;
chdir "$FindBin::Bin/.." or die "Cannot find repository root: $!";
open(my $in, '<', 'reports/sim.log') or die "Cannot read simulation log: $!";
my (@rows, %seen);
my ($started, $ended, $declared, $declared_failures, $invalid, $failed) = (0,0,0,0,0,0);
sub escape_html {
    my ($text) = @_;
    $text =~ s/&/&amp;/g; $text =~ s/</&lt;/g; $text =~ s/>/&gt;/g;
    return $text;
}
while (my $line = <$in>) {
    $started = 1 if $line =~ /\[SYSTEM\] SIMULATION_START/;
    if ($line =~ /\[SYSTEM\] SIMULATION_END Tests=(\d+) Failures=(\d+)/) {
        ($ended, $declared, $declared_failures) = (1, $1, $2);
    }
    next unless $line =~ /\[VERIFY\]/;
    if ($line =~ /\[VERIFY\] (TEST_CASE_\d+): Input=([0-9a-fxz]+) \| Output=([0-9a-fxz]+) \| Valid=([01xz]) \| EXPECTED:.*->\s*(PASS|FAIL)\s*$/i) {
        my ($id, $input, $output, $valid, $status) = ($1,$2,$3,$4,$5);
        $invalid++ if $seen{$id}++;
        $failed++ if $status ne 'PASS';
        push @rows, '<tr>' . join('', map { '<td>'.escape_html($_).'</td>' }
                    ($id, $input, $output, $valid, $status)) . '</tr>';
    } else { $invalid++; }
}
close $in;
my $total = scalar @rows;
my $complete = $started && $ended && $total > 0 && $total == $declared
               && $failed == $declared_failures && !$invalid;
my $passed = $complete && !$failed;
my $status = $passed ? 'PASS' : 'FAIL';
open(my $out, '>', 'reports/index.html') or die "Cannot write report: $!";
print $out "<!doctype html><html lang='en'><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>
<title>Hardware verification report</title>
<style>body{font:16px system-ui;max-width:960px;margin:3rem auto;padding:1rem}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ccc;padding:.6rem;text-align:left}</style>
<h1>Hardware verification: $status</h1><p>Checks: $total | Failed checks: $failed | Complete, valid log: ".($complete ? 'yes' : 'no')."</p>
<p>Simulation of an 8-bit threshold filter with synchronous reset. This report does not establish physical optical performance.</p>
<table><thead><tr><th>Test</th><th>Input (hex)</th><th>Output (hex)</th><th>Valid</th><th>Result</th></tr></thead><tbody>"
.join('', @rows)."</tbody></table></html>";
close $out;
print "Verification $status: $total checks, $failed failures. Report: reports/index.html\n";
exit($passed ? 0 : 1);
