module ALU (input wire [6:0] opcode,
            input wire [2:0] func3,
            input wire func7,
            input wire signed [31:0] operand1,
            input wire signed [31:0] operand2,
            output reg [31:0] alu_out);

parameter AND  = 3'b111;
parameter OR   = 3'b110;
parameter SR   = 3'b101;
parameter XOR  = 3'b100;
parameter SLL  = 3'b001;
parameter SLT  = 3'b010;
parameter SLTU = 3'b011;
parameter ADD  = 3'b000;


always @(*)
begin
    casex (opcode)
        7'b0x10011: begin
            case (func3)
                AND: alu_out  = operand1 & operand2;
                OR:  alu_out  = operand1 | operand2;
                XOR: alu_out  = operand1 ^ operand2;
                SR:  alu_out  = (func7 == 1'b1)? operand1 >>> (operand2%32) : operand1 >> ($unsigned(operand2)%32);
                SLL: alu_out  = operand1 << ($unsigned(operand2)%32);
                SLT: alu_out  = ($signed(operand1) < $signed(operand2))? 32'b1 : 32'b0;
                SLTU: alu_out = ($signed(operand1) < $unsigned(operand2))? 32'b1 : 32'b0;
                ADD:
                begin
                    if (opcode == 7'b0010011)
                    begin
                        alu_out = operand1 + operand2;
                    end
                    else
                    begin
                        alu_out = (func7)? operand1 - operand2 : operand1 + operand2;
                    end
                end
                default: alu_out = 32'h0;
            endcase
        end
        7'b0110111: alu_out = operand2;
        7'b0010111: alu_out = operand1 + operand2;
        7'b0x00011: alu_out = operand1 + operand2;
        7'b110x111: alu_out = operand1 + 32'd4;
        7'b1100011: begin
            case(func3)
                3'b000: alu_out  = (operand1 == operand2)? 32'b1 : 32'b0;
                3'b001: alu_out  = (operand1 != operand2)? 32'b1 : 32'b0;
                3'b100: alu_out  = ($signed(operand1) < $signed(operand2))? 32'b1 : 32'b0;
                3'b101: alu_out  = ($signed(operand1) >= $signed(operand2))? 32'b1 : 32'b0;
                3'b110: alu_out  = ($signed(operand1) < $unsigned(operand2))? 32'b1 : 32'b0;
                3'b111: alu_out  = ($signed(operand1) >= $unsigned(operand2))? 32'b1 : 32'b0;
                default: alu_out = 32'h0;
            endcase
        end
        default: alu_out = 32'h0;
    endcase
end
endmodule
