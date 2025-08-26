module SRAM (input wire clk,
             input wire [3:0]   w_en,
             input wire [15:0]  address,
             input wire [31:0]  write_data,
             output reg[31:0]   read_data);
    reg [7:0] mem [0:65535];
    reg [31:0] pass;
    
    always @(*) begin
        case(w_en)
            4'b1111: pass       <= write_data;
            4'b0011: pass[15:0] <= write_data[15:0] ;
            4'b0001: pass[7:0]  <= write_data[7:0] ;
        endcase
        read_data[7:0]   <= mem[address];
        read_data[15:8]  <= mem[address+1];
        read_data[23:16] <= mem[address+2];
        read_data[31:24] <= mem[address+3];
    end
    
    always@(posedge clk) begin
        case(w_en)
            4'b1111: begin
                mem[address]   <= pass[7:0];
                mem[address+1] <= pass[15:8];
                mem[address+2] <= pass[23:16];
                mem[address+3] <= pass[31:24];
            end
            4'b0011: begin
                mem[address]   <= pass[7:0];
                mem[address+1] <= pass[15:8];
            end
            4'b0001: begin
                mem[address] <= pass[7:0];
            end
            default: begin
            end
        endcase
    end
endmodule
