# Automated Hardware Verification Pipeline

![Verification Pipeline Demo](docs/hw_verification_demo.gif)

![Verification Pipeline Demo](docs/Screenshot_2026-07-07_160101.png)

## Overview
An end-to-end automated testing and verification pipeline for an optoelectronic signal filter. The module is designed in Verilog, simulated via Tcl automation, and analyzed using Perl to generate HTML compliance reports. 

This project bridges hardware description and software automation, demonstrating core continuous integration (CI) principles for FPGA and ASIC development environments.

## The Engineering Challenge
**Problem:** Manual verification of HDL modules is prone to human error, fails to easily capture edge-case regressions, and scales poorly in continuous integration environments. 

**Solution:** Architected a zero-touch verification pipeline.
- **EDA Automation:** Engineered **Tcl** scripts to natively manipulate the Icarus Verilog simulation environment, eliminating GUI overhead and standardizing test execution.
- **Data Extraction:** Deployed **Perl** scripts utilizing advanced regular expressions to parse raw simulation telemetry, extracting critical timing and logic state data.
- **Automated Reporting:** The pipeline culminates in an auto-generated HTML pass/fail matrix, translating complex diagnostic data into clear performance metrics.

## Advanced Test Coverage
The testbench is designed to push the hardware beyond standard "happy path" compliance, validating against real-world hardware anomalies:
1. **Standard Compliance:** Validates high/low signal triggers against hexadecimal thresholds.
2. **Sustained Optical Bursts:** Ensures the module holds valid flags open during multi-cycle signal saturation.
3. **Asynchronous Reset Overrides:** Proves the system safely drops to zero during a hardware reset, even if a valid signal is actively saturating the input.
4. **High-Frequency Noise:** Feeds the module rapid fluctuations of sub-threshold noise to verify resistance to false positives.

## Technology Stack
* **Hardware Description:** Verilog (Icarus Verilog / `iverilog`)
* **Automation Driver:** Tcl (`tclsh`)
* **Data Parsing:** Perl 
* **Version Control & OS:** Git / Linux (WSL)

## How to Execute
To run this pipeline locally and generate the verification report:
```bash
# 1. Clone the repository
git clone [https://github.com/EyitoCODE/automated-hw-verification.git](https://github.com/EyitoCODE/automated-hw-verification.git)

# 2. Navigate to the directory
cd automated-hw-verification

# 3. Execute the automation pipeline
tclsh scripts/run_sim.tcl
