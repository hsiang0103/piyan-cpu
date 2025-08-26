module control_E(input wire clk,
                 input wire rst,
                 input wire stall,
                 input wire jb,
                 input wire [6:0] E_in_op,
                 input wire [2:0] E_in_f3,
                 input wire E_in_f7,
                 input wire [4:0] E_in_rd,
                 input wire [4:0] E_in_rs1,
                 input wire [4:0] E_in_rs2,
                 input wire waiting,
                 output reg [6:0] E_out_op,
                 output reg [2:0] E_out_f3,
                 output reg E_out_f7,
                 output reg [4:0] E_out_rd,
                 output reg [4:0] E_out_rs1,
                 output reg [4:0] E_out_rs2);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            E_out_f3  <= 3'b0;
            E_out_op  <= 7'b0;
            E_out_rd  <= 5'b0;
            E_out_rs1 <= 5'b0;
            E_out_rs2 <= 5'b0;
            E_out_f7  <= 1'b0;
        end
        else begin
            if (waiting) begin
                E_out_f3  <= E_out_f3;
                E_out_op  <= E_out_op;
                E_out_rd  <= E_out_rd;
                E_out_rs1 <= E_out_rs1;
                E_out_rs2 <= E_out_rs2;
                E_out_f7  <= E_out_f7;
            end
            else if (stall || jb) begin
                E_out_f3  <= 3'b0;
                E_out_op  <= 7'b0;
                E_out_rd  <= 5'b0;
                E_out_rs1 <= 5'b0;
                E_out_rs2 <= 5'b0;
                E_out_f7  <= 1'b0;
            end
            else begin
                E_out_f3  <= E_in_f3;
                E_out_op  <= E_in_op;
                E_out_rd  <= E_in_rd;
                E_out_rs1 <= E_in_rs1;
                E_out_rs2 <= E_in_rs2;
                E_out_f7  <= E_in_f7;
            end
        end
    end
endmodule
