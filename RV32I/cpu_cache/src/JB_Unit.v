module JB_Unit (input wire [31:0] operand1,
                input wire [31:0] operand2,
                input wire [6:0] opcode,
                output reg [31:0] jb_out);
    wire [31:0] temp;
    assign temp = operand1 + operand2;
    
    always @(opcode or temp) begin
        if (opcode == 7'b1100111) begin
            jb_out = temp & 32'hfffffffe;
        end
        else begin
            jb_out = temp;
        end
    end
endmodule
