module control_W(input wire clk,
                 input wire rst,
                 input wire[4:0] W_in_op,
                 input wire[2:0] W_in_f3,
                 input wire[4:0] W_in_rd,
                 output reg[4:0] W_out_op,
                 output reg[2:0] W_out_f3,
                 output reg[4:0] W_out_rd);
    
    always@(posedge clk or posedge rst)
    begin
        if (rst) begin
            W_out_f3 <= 3'b0;
            W_out_op <= 5'b0;
            W_out_rd <= 5'b0;
        end
        else begin
            W_out_f3 <= W_in_f3;
            W_out_op <= W_in_op;
            W_out_rd <= W_in_rd;
        end
    end
endmodule
