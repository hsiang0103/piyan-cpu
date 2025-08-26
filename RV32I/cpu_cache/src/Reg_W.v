module Reg_W(input wire clk,
             input wire rst,
             input wire waiting,
             input wire [31:0] W_in_alu_out,
             input wire [31:0] W_in_ld_data,
             output reg [31:0] W_out_alu_out,
             output reg [31:0] W_out_ld_data);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            W_out_alu_out <= 32'd0;
            W_out_ld_data <= 32'd0;
        end
        else begin
            if (waiting) begin
                W_out_alu_out <= W_out_alu_out;
                W_out_ld_data <= W_out_ld_data;
            end
            else  begin
                W_out_alu_out <= W_in_alu_out;
                W_out_ld_data <= W_in_ld_data;
            end
        end
    end
endmodule
