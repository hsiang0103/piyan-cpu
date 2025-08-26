module Reg_PC(input wire clk,
              input wire rst,
              input wire[31:0] next_pc,
              input wire stall,
              input wire waiting,
              output reg[31:0] current_pc);
    
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            current_pc <= 32'd0;
        end
        else begin
            if (stall || waiting) begin
                current_pc <= current_pc;
            end
            else begin
                current_pc <= next_pc;
            end
        end
    end
endmodule
