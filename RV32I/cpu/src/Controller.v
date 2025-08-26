/*`include "./src/control_E.v"
`include "./src/control_W.v"
`include "./src/control_M.v"*/
/*
 `include "control_E.v"
 `include "control_W.v"
 `include "control_M.v"*/


module Controller (input wire[4:0] opcode,
                   input wire[2:0] func3,
                   input wire func7,
                   input wire[4:0] rd,
                   input wire[4:0] rs1,
                   input wire[4:0] rs2,
                   input wire alu_out,
                   input wire clk,
                   input wire rst,
                   output reg next_pc_sel,
                   output reg[3:0] F_im_w_en,
                   output reg D_rs1_data_sel,
                   output reg D_rs2_data_sel,
                   output reg[1:0] E_rs1_data_sel,
                   output reg[1:0] E_rs2_data_sel,
                   output reg E_jb_op1_sel,
                   output reg E_alu_op1_sel,
                   output reg E_alu_op2_sel,
                   output reg W_wb_data_sel,
                   output reg W_wb_en,
                   output reg[3:0] M_dm_w_en,
                   output wire [4:0] E_op,
                   output wire [2:0] E_f3,
                   output wire E_f7,
                   output wire [4:0] E_rd,
                   output wire [2:0] W_f3,
                   output wire [4:0] W_rd,
                   output reg stall);
    parameter R_type = 5'b01100;
    parameter I_type = 5'b00100;
    parameter load   = 5'b00000;
    parameter JALR   = 5'b11001;
    parameter S_type = 5'b01000;
    parameter B_type = 5'b11000;
    parameter JAL    = 5'b11011;
    parameter LUI    = 5'b01101;
    parameter auipc  = 5'b00101;
    
    wire [4:0] E_rs1;
    wire [4:0] E_rs2;
    wire [4:0] M_op;
    wire [2:0] M_f3;
    wire [4:0] M_rd;
    wire [4:0] W_op;
    
    
    control_E CE(
    .clk(clk) ,
    .rst(rst) ,
    .stall(stall),
    .jb(next_pc_sel),
    .E_in_op(opcode),
    .E_in_f3(func3),
    .E_in_rd(rd),
    .E_in_rs1(rs1),
    .E_in_rs2(rs2),
    .E_in_f7(func7),
    .E_out_op(E_op),
    .E_out_f3(E_f3),
    .E_out_rd(E_rd),
    .E_out_f7(E_f7),
    .E_out_rs1(E_rs1),
    .E_out_rs2(E_rs2)
    );
    
    control_M CM(
    .clk(clk) ,
    .rst(rst) ,
    .M_in_op(E_op),
    .M_in_f3(E_f3),
    .M_in_rd(E_rd),
    .M_out_op(M_op),
    .M_out_f3(M_f3),
    .M_out_rd(M_rd)
    );
    
    control_W CW(
    .clk(clk) ,
    .rst(rst) ,
    .W_in_op(M_op),
    .W_in_f3(M_f3),
    .W_in_rd(M_rd),
    .W_out_op(W_op),
    .W_out_f3(W_f3),
    .W_out_rd(W_rd)
    );
    
    always @(opcode or rd or rs1 or rs2 or alu_out or E_rs1 or E_rs2 or E_rd or E_op or M_op or M_f3 or M_rd or W_op or W_f3 or W_rd)
    begin
        if (E_op >= 5'd0) begin
            casex(E_op)
                B_type:     next_pc_sel = alu_out;
                5'b110x1:   next_pc_sel = 1'b1;
                default:    next_pc_sel = 1'b0;
            endcase
        end
        else begin
            next_pc_sel = 1'b0;
        end
        F_im_w_en = 4'b0000;
        if (M_op == S_type) begin
            case (M_f3)
                3'b000:     M_dm_w_en = 4'b0001;
                3'b001:     M_dm_w_en = 4'b0011;
                3'b010:     M_dm_w_en = 4'b1111;
                default:    M_dm_w_en = 4'b0000;
            endcase
        end
        else begin
            M_dm_w_en = 4'b0000;
        end
        W_wb_en       = (W_op == R_type || W_op == load || W_op == I_type || W_op == JALR || W_op == JAL || W_op == auipc || W_op == LUI)? 1'b1 : 1'b0;
        E_alu_op1_sel = (E_op != JAL && E_op != auipc && E_op != LUI && E_op != JALR)? 1'b1 : 1'b0;
        E_alu_op2_sel = (E_op == B_type || E_op == R_type)? 1'b1 : 1'b0;
        E_jb_op1_sel  = (E_op == JALR)? 1'b1 : 1'b0;
        W_wb_data_sel = (W_op == load)? 1'b1 : 1'b0;
        
        //D_rs1_data_sel//
        if ((opcode != LUI && opcode != auipc && opcode != JAL) && (W_op != B_type && W_op != S_type))
        begin
            if ((W_rd != 5'd0) && (rs1 == W_rd)) begin
                D_rs1_data_sel = 1'b1;
            end
            else begin
                D_rs1_data_sel = 1'b0;
            end
        end
        else begin
            D_rs1_data_sel = 1'b0;
        end
        //D_rs2_data_sel//
        if ((opcode == B_type || opcode == S_type || opcode == R_type) && (W_op != B_type && W_op != S_type)) begin
            if ((W_rd != 5'd0) && (rs2 == W_rd)) begin
                D_rs2_data_sel = 1'b1;
            end
            else begin
                D_rs2_data_sel = 1'b0;
            end
        end
        else begin
            D_rs2_data_sel = 1'b0;
        end
        
        //E_rs1_data_sel//
        if ((E_op != LUI && E_op != auipc && E_op != JAL) && (M_op != B_type && M_op != S_type)) begin
            if ((E_rs1 == M_rd) && (M_rd != 5'b0)) begin
                E_rs1_data_sel = 2'd1;
            end
            else if ((E_op != LUI && E_op != auipc && E_op != JAL) && (W_op != B_type && W_op != S_type)) begin
                if ((E_rs1 == W_rd) && (W_rd != 5'b0)) begin
                    E_rs1_data_sel = 2'd0;
                end
                else begin
                    E_rs1_data_sel = 2'd2;
                end
            end
            else begin
                E_rs1_data_sel = 2'd2;
            end
        end
        else if ((E_op != LUI && E_op != auipc && E_op != JAL) && (W_op != B_type && W_op != S_type)) begin
            if ((E_rs1 == W_rd) && (W_rd != 5'b0)) begin
                E_rs1_data_sel = 2'd0;
            end
            else begin
                E_rs1_data_sel = 2'd2;
            end
        end
        else begin
            E_rs1_data_sel = 2'd2;
        end
        //E_rs2_data_sel//
        if ((E_op == B_type || E_op == S_type || E_op == R_type) && (M_op != B_type && M_op != S_type)) begin
            if ((E_rs2 == M_rd) && (M_rd != 5'b0)) begin
                E_rs2_data_sel = 2'd1;
            end
            else if ((E_op == B_type || E_op == S_type || E_op == R_type) && (W_op != B_type && W_op != S_type)) begin
                if ((E_rs2 == W_rd) && (W_rd != 5'b0)) begin
                    E_rs2_data_sel = 2'd0;
                end
                else begin
                    E_rs2_data_sel = 2'd2;
                end
            end
            else begin
                E_rs2_data_sel = 2'd2;
            end
        end
        else if ((E_op == B_type || E_op == S_type || E_op == R_type) && (W_op != B_type && W_op != S_type)) begin
            if ((E_rs2 == W_rd) && (W_rd != 5'b0)) begin
                E_rs2_data_sel = 2'd0;
            end
            else begin
                E_rs2_data_sel = 2'd2;
            end
        end
        else begin
            E_rs2_data_sel = 2'd2;
        end
        
        //stall//
        if (E_op == load) begin
            if (((opcode != LUI && opcode != auipc && opcode != JAL)
                && (E_rd != 5'd0) && (rs1 == E_rd)) ||
                ((opcode == B_type || opcode == S_type || opcode == R_type) &&
                (E_rd != 5'd0) && (rs2 == E_rd))) begin
                stall = 1'd1;
                end
            else begin
                stall = 1'd0;
            end
        end
        else begin
            stall = 1'd0;
        end
    end
endmodule
