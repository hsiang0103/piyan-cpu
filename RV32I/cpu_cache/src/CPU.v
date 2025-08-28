module CPU (input wire clk,
            // input wire waiting,
            input wire rst);
    
    wire [3:0] F_im_w_en;
    wire [3:0] M_dm_w_en;
    wire [31:0] pc;
    wire [31:0] M_out_alu_out;
    wire [31:0] D_in_inst;
    wire [31:0] M_out_rs2_data;
    wire [31:0] W_in_ld_data;
    wire [15:0] rd_addr;
    wire [15:0] wr_addr;
    wire [31:0] data_out;
    wire [31:0] data2mem;
    wire read;
    wire [3:0] write;
    wire mrden, mwren, hit_miss;
    wire data_ready;
    wire dmem_data_ready;
 

    Top t1(
    .clk(clk),
    .rst(rst),
    .M_out_rs2_data(M_out_rs2_data),
    .W_in_ld_data(W_in_ld_data),
    .F_im_w_en(F_im_w_en),
    .M_dm_w_en(M_dm_w_en),
    .pc(pc),
    .M_out_alu_out(M_out_alu_out),
    .D_in_inst(D_in_inst),
    .read(read),
    .write(write),
    .data_ready(data_ready)    
    );
    
    SRAM im(
    .clk(clk),
    .w_en(F_im_w_en),
    .address(pc[15:0]),
    .write_data(32'b0),
    .read_data(D_in_inst)
    );

    
    dcache Dcache (
    .clk(clk),
    .rst(rst),
    .address(M_out_alu_out[15:0]),
    .data_in_cpu(M_out_rs2_data),
    .data_in_mem(data_out),
    .data_in_mem_ready(dmem_data_ready),
    .rd(read),
    .wr(write),
    .hit_miss(hit_miss),
    .data2cpu(W_in_ld_data),
    .data2mem(data2mem),
    .m_rd_address(rd_addr),
    .m_wr_address(wr_addr),
    .mrden(mrden),
    .mwren(mwren),
    .data_ready(data_ready)
    );
    
    Data_mem dm (
    .clk(clk),
    .write_data(data2mem),
    .rdaddress(rd_addr),
    .wraddress(wr_addr),
    .rden(mrden),
    .wren(mwren),
    .read_data(data_out),
    .rst(rst),
    .ready(dmem_data_ready)
    );
endmodule
