`timescale 1ns/1ps
module opto_filter_tb;
    reg clk = 0;
    reg rst = 1;
    reg [7:0] signal_in = 0;
    wire [7:0] signal_out;
    wire valid_flag;
    integer tests = 0;
    integer failures = 0;
    opto_filter uut(.clk(clk), .rst(rst), .signal_in(signal_in),
                    .signal_out(signal_out), .valid_flag(valid_flag));
    always #5 clk = ~clk;

    // Drive at the falling edge; sample after nonblocking assignments settle.
    task check;
        input [7:0] value;
        input reset;
        input [7:0] expected_out;
        input expected_valid;
        reg passed;
        begin
            @(negedge clk);
            signal_in = value;
            rst = reset;
            @(posedge clk);
            #1;
            tests = tests + 1;
            passed = (signal_out === expected_out) && (valid_flag === expected_valid);
            if (!passed) failures = failures + 1;
            $display("[VERIFY] TEST_CASE_%0d: Input=%h | Output=%h | Valid=%b | EXPECTED: Output=%h Valid=%b -> %s",
                     tests, signal_in, signal_out, valid_flag, expected_out,
                     expected_valid, passed ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("[SYSTEM] SIMULATION_START");
        check(8'h00, 1, 8'h00, 0);
        check(8'h00, 0, 8'h00, 0);
        check(8'h31, 0, 8'h00, 0);
        check(8'h32, 0, 8'h00, 0);
        check(8'h33, 0, 8'h33, 1);
        check(8'hff, 0, 8'hff, 1);
        // Sustained valid input: check each cycle.
        repeat (3) check(8'haa, 0, 8'haa, 1);
        // RTL has a synchronous reset: verify on a rising edge.
        check(8'hff, 1, 8'h00, 0);
        check(8'hff, 0, 8'hff, 1);
        check(8'h22, 0, 8'h00, 0);
        check(8'h15, 0, 8'h00, 0);
        check(8'h2f, 0, 8'h00, 0);
        $display("[SYSTEM] SIMULATION_END Tests=%0d Failures=%0d", tests, failures);
        if (failures > 0) $fatal(1, "Verification failed");
        $finish;
    end
endmodule
