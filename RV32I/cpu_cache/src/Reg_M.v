module Reg_M(input wire clk,
             input wire rst,
             input wire waiting,
             input wire [31:0] M_in_alu_out,
             input wire [31:0] M_in_rs2_data,
             output reg [31:0] M_out_alu_out,
             output reg [31:0] M_out_rs2_data);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            M_out_alu_out  <= 32'd0;
            M_out_rs2_data <= 32'd0;
        end
        else begin
            if (waiting) begin
                M_out_alu_out  <= M_out_alu_out;
                M_out_rs2_data <= M_out_rs2_data;
            end
            else begin
                M_out_alu_out  <= M_in_alu_out;
                M_out_rs2_data <= M_in_rs2_data;
            end
        end
    end
endmodule
