module Imme_Ext (input wire [31:0] inst,
                 output reg[31:0] imm_ext_out);
    wire [6:0] opcode;
    parameter R_type = 7'b0110011;
    parameter I_type = 7'b0010011;
    parameter load   = 7'b0000011;
    parameter JALR   = 7'b1100111;
    parameter S_type = 7'b0100011;
    parameter B_type = 7'b1100011;
    parameter JAL    = 7'b1101111;
    parameter LUI    = 7'b0110111;
    parameter auipc  = 7'b0010111;
    
    assign opcode = inst[6:0];
    
    always @(inst[31:7] or opcode) begin
        case(opcode)
            R_type: imm_ext_out = 32'b0;
            I_type: begin
                if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
                    imm_ext_out = {{27{1'b0}} , inst[24:20]};
                end
                else begin
                    imm_ext_out = {{20{inst[31]}} , inst[31:20]};
                end
            end
            load:   imm_ext_out = {{20{inst[31]}} , inst[31:20]};
            JALR:   imm_ext_out = {{20{inst[31]}} , inst[31:20]};
            S_type: imm_ext_out = {{20{inst[31]}} , inst[31:25] , inst[11:7]};
            B_type: imm_ext_out = {{20{inst[31]}} , inst[7] , inst[30:25] , inst[11:8] , 1'b0};
            LUI:    imm_ext_out = {inst[31:12] , 12'b0};
            auipc:  imm_ext_out = {inst[31:12] , 12'b0};
            JAL:    imm_ext_out = {{12{inst[31]}} , inst[19:12] , inst[20] , inst[30:21] , 1'b0};
            default:imm_ext_out = 32'h0;
        endcase
    end
endmodule
