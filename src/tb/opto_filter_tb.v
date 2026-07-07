`timescale 1ns/1ps

module opto_filter_tb;
    reg clk;
    reg rst;
    reg [7:0] signal_in;
    wire [7:0] signal_out;
    wire valid_flag;

    // Instantiate the Unit Under Test (UUT)
    opto_filter uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .signal_out(signal_out),
        .valid_flag(valid_flag)
    );

    // Clock Generation (10ns period -> 100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("[SYSTEM] SIMULATION_START");
        
        // Initialize
        rst = 1; signal_in = 8'h00; #15;
        rst = 0;

        // ----------------------------------------------------
        // STANDARD COMPLIANCE TESTS
        // ----------------------------------------------------
        // Test Case 1: Baseline Noise (Below Threshold)
        signal_in = 8'h10; #10;
        $display("[VERIFY] TEST_CASE_1: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=0 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 0) ? "PASS" : "FAIL");

        // Test Case 2: Valid Signal Activation (Above Threshold)
        signal_in = 8'h45; #10;
        $display("[VERIFY] TEST_CASE_2: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=1 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 1) ? "PASS" : "FAIL");

        // Test Case 3: Threshold Edge Case (Exact Threshold)
        signal_in = 8'h32; #10;
        $display("[VERIFY] TEST_CASE_3: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=0 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 0) ? "PASS" : "FAIL");

        // ----------------------------------------------------
        // ADVANCED EDGE-CASE TESTS
        // ----------------------------------------------------
        // Test Case 4: Sustained Optical Burst (Multiple Cycles)
        signal_in = 8'hAA; #30; // Hold for 3 clock cycles
        $display("[VERIFY] TEST_CASE_4: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=1 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 1) ? "PASS" : "FAIL");

        // Test Case 5: Asynchronous System Reset Override
        // Introduce a massive signal, but trigger reset simultaneously
        signal_in = 8'hFF; rst = 1; #10;
        $display("[VERIFY] TEST_CASE_5: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=0 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 0) ? "PASS" : "FAIL");
        
        rst = 0; #10; // System Recovery

        // Test Case 6: High-Frequency Noise Burst
        signal_in = 8'h22; #10;
        signal_in = 8'h15; #10;
        signal_in = 8'h2F; #10;
        $display("[VERIFY] TEST_CASE_6: Input=%h | Output=%h | Valid=%b | EXPECTED: Valid=0 -> %s", 
                 signal_in, signal_out, valid_flag, (valid_flag == 0) ? "PASS" : "FAIL");

        $display("[SYSTEM] SIMULATION_END");
        $finish;
    end
endmodule