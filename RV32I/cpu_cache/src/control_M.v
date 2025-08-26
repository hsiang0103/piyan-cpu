module control_M(input wire clk,
                 input wire rst,
                 input wire [6:0] M_in_op,
                 input wire [2:0] M_in_f3,
                 input wire [4:0] M_in_rd,
                 input wire waiting,
                 output reg [6:0] M_out_op,
                 output reg [2:0] M_out_f3,
                 output reg [4:0] M_out_rd);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            M_out_f3 <= 3'b0;
            M_out_op <= 7'b0;
            M_out_rd <= 5'b0;
        end
        else begin
            if (waiting) begin
                M_out_f3 <= M_out_f3;
                M_out_op <= M_out_op;
                M_out_rd <= M_out_rd;
            end
            else begin
                M_out_f3 <= M_in_f3;
                M_out_op <= M_in_op;
                M_out_rd <= M_in_rd;
            end
        end
    end
endmodule
