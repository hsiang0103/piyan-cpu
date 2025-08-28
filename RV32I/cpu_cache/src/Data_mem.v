// no synthesis
module Data_mem (input wire clk,
                 input wire rst,
                 input wire rden,
                 input wire wren,
                 input wire [15:0] rdaddress,
                 input wire [15:0] wraddress,
                 input wire [31:0] write_data,
                 output reg [31:0] read_data,
                 output wire ready);
        

    reg [7:0] mem [0:65535];
    integer i;

    reg [7:0] delay_cnt;
    reg [7:0] delay_val;
    reg pending_read;
    reg [15:0] pending_rdaddress;

    assign ready = (delay_cnt == delay_val) && pending_read;
    
    // read logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_cnt       <= 0;
            delay_val       <= 0;
            pending_read    <= 0;
            read_data       <= 0;
        end 
        else begin
            if (rden && !pending_read) begin
                delay_val           <= ($random % 8) + 1; 
                delay_cnt           <= 0;
                pending_read        <= 1;
                pending_rdaddress   <= rdaddress;
            end
            if (pending_read) begin
                if (delay_cnt < delay_val) begin
                    delay_cnt <= delay_cnt + 1;
                end
                else begin
                    read_data           <= mem[pending_rdaddress];
                    read_data[15:8]     <= mem[pending_rdaddress+1];
                    read_data[23:16]    <= mem[pending_rdaddress+2];
                    read_data[31:24]    <= mem[pending_rdaddress+3];
                    pending_read        <= 0;
                end
            end
        end
    end

    // Write logic
    always @(posedge clk or posedge rst) begin
        if (wren) begin
            mem[wraddress]   <= write_data[7:0];
            mem[wraddress+1] <= write_data[15:8];
            mem[wraddress+2] <= write_data[23:16];
            mem[wraddress+3] <= write_data[31:24];
        end
    end

endmodule
