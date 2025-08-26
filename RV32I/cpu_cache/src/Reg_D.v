module Reg_D(input wire clk,
             input wire rst,
             input wire [31:0] D_in_inst,
             input wire [31:0] D_in_pc,
             input wire jb,
             input wire stall,
             input wire waiting,
             output reg [31:0] D_out_inst,
             output reg [31:0] D_out_pc);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            D_out_inst <= 32'b0;
            D_out_pc   <= 32'b0;
        end
        else begin
            if (stall || waiting) begin
                D_out_inst <= D_out_inst;
                D_out_pc   <= D_out_pc;
            end
            else if (jb) begin
                D_out_inst <= 32'h00000013;
                D_out_pc   <= 32'd0;
            end
            else begin
                D_out_inst <= D_in_inst;
                D_out_pc   <= D_in_pc;
            end
        end
    end
endmodule
