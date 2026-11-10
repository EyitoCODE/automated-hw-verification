# Automated Hardware Verification Pipeline

A reproducible Verilog → Tcl → Perl workflow for an 8-bit threshold filter.
It compiles RTL, runs a self-checking testbench, and produces an HTML report.
Failures propagate to the shell and GitHub Actions.

## Run

Requires Icarus Verilog (iverilog and vvp), Tcl 8.6+, and Perl.
On Ubuntu: `sudo apt-get install iverilog tcl perl`.

```bash
git clone https://github.com/EyitoCODE/automated-hw-verification.git
cd automated-hw-verification
tclsh scripts/run_sim.tcl
```

The script creates `reports/` automatically and works when invoked by absolute
path from another directory. Open `reports/index.html`; raw output is in
`reports/sim.log`. Exit status is nonzero for compilation, simulation, parser,
failed checks, empty logs, duplicate checks, or incomplete runs.

## What is verified

The RTL passes input values strictly greater than 0x32 (decimal 50); other
values produce zero output and an invalid flag. Reset is **synchronous**.

Fourteen cycle-level checks cover reset, zero input, threshold boundaries
(49, 50, 51), maximum input, sustained valid input, reset during a strong signal,
recovery, and multiple sub-threshold noise values. Each check verifies both
the output data and the valid flag, using case equality to catch unknown states.

## Continuous integration

GitHub Actions installs the simulator, runs verification and failure-path
regression tests, and uploads the log and HTML report even when a run fails.

```bash
python3 -m unittest discover -s tests -v
```

The regression suite also mutates the threshold in a temporary copy to verify
that incorrect RTL causes a failing process exit and a failing report.

## Scope

This is a digital simulation and automation demonstration. It has not been
synthesized, run on an FPGA, or validated against a physical optical sensor.
The test count is directed coverage, not exhaustive functional or code coverage.
