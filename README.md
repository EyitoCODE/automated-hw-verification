# Automated Hardware Verification Pipeline

## Overview
An end-to-end automated testing and verification pipeline for an optoelectronic signal filter. The module is designed in Verilog, simulated via Tcl automation, and analyzed using Perl to generate compliance reports.

## The Engineering Challenge
**Problem:** Manual verification of HDL modules is prone to human error and scales poorly in continuous integration environments. 
**Solution:** Architected a zero-touch verification pipeline to bridge hardware design and software testing.
- **EDA Automation:** Engineered Tcl scripts to manipulate the simulation environment natively, eliminating GUI overhead and standardizing the test execution.
- **Data Extraction:** Deployed Perl scripts utilizing advanced regular expressions to parse raw simulation telemetry, extracting critical timing and logic state data.
- **Automated Reporting:** The pipeline culminates in an auto-generated HTML pass/fail matrix, demonstrating the ability to translate complex diagnostic data into clear performance reports.

## Technology Stack
* **Hardware Description:** Verilog
* **Automation:** Tcl
* **Data Parsing:** Perl
* **Version Control & OS:** Git / Linux