module Reg_E(input wire clk,
             input wire rst,
             input wire [31:0] E_in_rs1_data,
             input wire [31:0] E_in_rs2_data,
             input wire [31:0] E_in_sext_imme,
             input wire [31:0] E_in_pc,
             input wire jb,
             input wire stall,
             input wire waiting,
             output reg [31:0] E_out_rs1_data,
             output reg [31:0] E_out_rs2_data,
             output reg [31:0] E_out_sext_imme,
             output reg [31:0] E_out_pc);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            E_out_rs1_data  <= 32'd0;
            E_out_rs2_data  <= 32'd0;
            E_out_sext_imme <= 32'd0;
            E_out_pc        <= 32'd0;
        end
        else begin
            if (waiting) begin
                E_out_rs1_data  <= E_out_rs1_data;
                E_out_rs2_data  <= E_out_rs2_data;
                E_out_sext_imme <= E_out_sext_imme;
                E_out_pc        <= E_out_pc;
            end
            else if (stall || jb) begin
                E_out_rs1_data  <= 32'd0;
                E_out_rs2_data  <= 32'd0;
                E_out_sext_imme <= 32'd0;
                E_out_pc        <= E_in_pc;
            end
            else begin
                E_out_rs1_data  <= E_in_rs1_data;
                E_out_rs2_data  <= E_in_rs2_data;
                E_out_sext_imme <= E_in_sext_imme;
                E_out_pc        <= E_in_pc;
            end
        end
    end
endmodule
