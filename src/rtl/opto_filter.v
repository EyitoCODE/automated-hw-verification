module opto_filter (
    input wire clk,
    input wire rst,
    input wire [7:0] signal_in,
    output reg [7:0] signal_out,
    output reg valid_flag
);
    // Threshold set to hex 32 (decimal 50)
    localparam THRESHOLD = 8'h32;

    always @(posedge clk) begin
        if (rst) begin
            signal_out <= 8'b0;
            valid_flag <= 1'b0;
        end else if (signal_in > THRESHOLD) begin
            signal_out <= signal_in;
            valid_flag <= 1'b1;
        end else begin
            signal_out <= 8'b0;
            valid_flag <= 1'b0;
        end
    end
endmodule