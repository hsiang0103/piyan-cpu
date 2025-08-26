module Adder(
    input wire [31:0] curr_pc,
    input wire clk,
    output reg [31:0] next_pc
);
    always @(curr_pc) begin
        next_pc <= curr_pc + 32'd4;
    end
endmodule