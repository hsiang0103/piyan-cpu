module Controller (
    input wire[6:0] opcode,
    input wire[2:0] func3,
    input wire func7,
    input wire[4:0] rd,
    input wire[4:0] rs1,
    input wire[4:0] rs2,
    input wire alu_out,
    input wire clk,
    input wire rst,
    input wire data_ready,//
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
    output wire [3:0] M_dm_w_en,
    output wire [6:0] E_op,
    output wire [2:0] E_f3,
    output wire E_f7,
    output wire [4:0] E_rd,// trash
    output wire [2:0] W_f3,
    output wire [4:0] W_rd,
    output reg stall,
    output wire waiting,//
    output wire read,//
    output wire [3:0] write // trash
);

    parameter R_type = 7'b0110011;
    parameter I_type = 7'b0010011;
    parameter LOAD   = 7'b0000011;
    parameter JALR   = 7'b1100111;
    parameter S_type = 7'b0100011;
    parameter B_type = 7'b1100011;
    parameter JAL    = 7'b1101111;
    parameter LUI    = 7'b0110111;
    parameter AUIPC  = 7'b0010111;
    
    wire [4:0] E_rs1;
    wire [4:0] E_rs2;
    wire [6:0] M_op;
    wire [2:0] M_f3;
    wire [4:0] M_rd;
    wire [6:0] W_op;
    
    
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
    .E_out_rs2(E_rs2),
    .waiting(waiting)
    );
    
    control_M CM(
    .clk(clk) ,
    .rst(rst) ,
    .M_in_op(E_op),
    .M_in_f3(E_f3),
    .M_in_rd(E_rd),
    .M_out_op(M_op),
    .M_out_f3(M_f3),
    .M_out_rd(M_rd),
    .waiting(waiting)
    );
    
    control_W CW(
    .clk(clk) ,
    .rst(rst) ,
    .W_in_op(M_op),
    .W_in_f3(M_f3),
    .W_in_rd(M_rd),
    .W_out_op(W_op),
    .W_out_f3(W_f3),
    .W_out_rd(W_rd),
    .waiting(waiting)
    );
    
    assign waiting = ((M_op == LOAD || M_dm_w_en) && !data_ready);
    assign read = (M_op == LOAD);
    assign write = M_dm_w_en;
    assign M_dm_w_en = (M_op == S_type)? ((M_f3 == 3'b000)? (4'b001) : ((M_f3 == 3'b001)? (4'b0011) : (4'b1111))) : (4'b0);
    // assign waiting = 0;
    
    always @(*) begin
        F_im_w_en     = 4'b0000;
        W_wb_en       = (W_op == R_type || W_op == LOAD || W_op == I_type || W_op == JALR || W_op == JAL || W_op == AUIPC || W_op == LUI)? 1'b1 : 1'b0;
        E_alu_op1_sel = (E_op != JAL && E_op != AUIPC && E_op != LUI && E_op != JALR)? 1'b1 : 1'b0;
        E_alu_op2_sel = (E_op == B_type || E_op == R_type)? 1'b1 : 1'b0;
        E_jb_op1_sel  = (E_op == JALR)? 1'b1 : 1'b0;
        W_wb_data_sel = (W_op == LOAD)? 1'b1 : 1'b0;

        if (E_op >= 7'd0) begin
            casex(E_op)
                B_type:     next_pc_sel = alu_out;
                7'b110x111: next_pc_sel = 1'b1;
                default:    next_pc_sel = 1'b0;
            endcase
        end
        else begin
            next_pc_sel = 1'b0;
        end

        //D_rs1_data_sel//
        if ((opcode != LUI && opcode != AUIPC && opcode != JAL) && (W_op != B_type && W_op != S_type)) begin
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
        if ((E_op != LUI && E_op != AUIPC && E_op != JAL) && (M_op != B_type && M_op != S_type)) begin
            if ((E_rs1 == M_rd) && (M_rd != 5'b0)) begin
                E_rs1_data_sel = 2'd1;
            end
            else if ((E_op != LUI && E_op != AUIPC && E_op != JAL) && (W_op != B_type && W_op != S_type)) begin
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
        else if ((E_op != LUI && E_op != AUIPC && E_op != JAL) && (W_op != B_type && W_op != S_type)) begin
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
        if (E_op == LOAD) begin
            if (((opcode != LUI && opcode != AUIPC && opcode != JAL)
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
