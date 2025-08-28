`define TAG 15:7		// position of tag in address
`define INDEX 6:2	    // position of index in address
`define OFFSET 1:0		// position of offset in address
`define MEMORY_READ_DELAY 10

//  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
// |-----------------------|---------|---|
// |TAG                    |INDEX    |OFF|

module dcache (input wire clk,
               input wire rst,
               input wire [15:0] address,       // address form CPU
               input wire [31:0] data_in_cpu,   // data from CPU
               input wire [31:0] data_in_mem,   // data from memory
               input wire data_in_mem_ready,
               input wire rd,                   // read instruction, 1 for load instruction
               input wire [3:0] wr,             // write instruction, 1 for store instruction
               output wire data_ready,
               output wire hit_miss,            // 1 for hit, 0 while handling miss
               output reg [31:0]  data2cpu,     // data from cache to CPU
               output reg [31:0]  data2mem,     // data from cache to memory
               output reg [15:0]  m_wr_address, // memory write address
               output wire [15:0] m_rd_address, // memory read address
               output wire mrden,               // read enable, 1 for reading from memory
               output reg  mwren);              // write enable, 1 for writing to memory
    
    // WAY 1 cache data
    reg					valid1 [0:31];
    reg					dirty1 [0:31];
    reg					lru1   [0:31];
    reg [8:0]	        tag1   [0:31];
    reg [31:0]	        mem1   [0:31];
    
    // WAY 2 cache data
    reg					valid2 [0:31];
    reg					dirty2 [0:31];
    reg					lru2   [0:31];
    reg [8:0]           tag2   [0:31];
    reg [31:0]          mem2   [0:31];
    
    parameter IDLE    = 0;
    parameter MISS    = 1;
    parameter WAITMEM = 2;
    parameter DONE    = 3;
    integer i;
    
    reg [1:0] cs, ns;
    wire [31:0] mask;
    
    assign mrden        = cs == WAITMEM;
    assign m_rd_address = address;
    assign data_ready   = cs == DONE;
    assign mask         = (wr == 4'b1111)? 32'hFFFFFFFF : (wr == 4'b0011)? 32'h0000FFFF : (wr == 4'b0001)? 32'h000000FF : 32'b0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cs <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end
    
    assign hit_miss = (rd || wr) && (cs == IDLE) && ((valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG])) || (valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])));

    always @(*) begin
        case(cs)
            // IDLE:   ns  = (rd || wr)? ((rd)? ((hit_miss)? (DONE) : (WAITMEM)) : ((hit_miss)? (DONE) : (MISS))) : (IDLE);
            IDLE:   ns  = (rd)? ((hit_miss)? DONE : WAITMEM) : ((wr)? ((hit_miss)? DONE : MISS) : IDLE);
            MISS:   ns  = DONE;
            WAITMEM: ns = (data_in_mem_ready)? MISS : WAITMEM;
            DONE:   ns  = IDLE;
            default:ns  = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                valid1[i] <= 0;
                valid2[i] <= 0;
                dirty1[i] <= 0;
                dirty2[i] <= 0;
                lru1[i]   <= 0;
                lru2[i]   <= 0;
                mem1[i]   <= 0;
                mem2[i]   <= 0;
                tag1[i]   <= 0;
                tag2[i]   <= 0;
            end
            data2mem     <= 0;
            mwren        <= 0;
            m_wr_address <= 0;
            data2cpu     <= 0;
        end
        else begin
            case(cs)
                IDLE: begin
                    if (hit_miss) begin
                        if (valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG])) begin
                            if (rd) begin // read
                                data2cpu <= mem1[address[`INDEX]];
                            end
                            else begin  // write
                                data2cpu                <= 32'b0;
                                mem1[address[`INDEX]]   <= mask & data_in_cpu;
                                dirty1[address[`INDEX]] <= 1;
                            end
                            // one for recent used
                            lru1[address[`INDEX]] <= 1;
                            lru2[address[`INDEX]] <= 0;
                        end
                        else begin
                            if (rd) begin // read
                                data2cpu <= mem2[address[`INDEX]];
                            end
                            else begin // write
                                data2cpu                <= 32'b0;
                                mem2[address[`INDEX]]   <= mask & data_in_cpu;
                                dirty2[address[`INDEX]] <= 1;
                            end
                            lru1[address[`INDEX]] <= 0;
                            lru2[address[`INDEX]] <= 1;
                        end
                    end
                    else begin
                        data2cpu <= 0;
                    end
                end
                MISS:
                begin
                    // read miss, take data from memory
                    if (rd) begin
                        data2cpu <= data_in_mem;
                    end
                    else begin
                        data2cpu <= 0;
                    end
                    
                    // check way 1
                    if (lru1[address[`INDEX]] == 0) begin
                        // if dirty, write back to memory
                        if (dirty1[address[`INDEX]] == 1) begin
                            m_wr_address <= {tag1[address[`INDEX]],address[`INDEX],2'b0};
                            mwren        <= 1;
                            data2mem     <= mem1[address[`INDEX]];
                        end
                        // write allocate
                        tag1[address[`INDEX]]   <= address[`TAG];
                        valid1[address[`INDEX]] <= 1;
                        lru1[address[`INDEX]]   <= 1;
                        lru2[address[`INDEX]]   <= 0;
                        if (rd) begin // read miss
                            dirty1[address[`INDEX]] <= 0;
                            mem1[address[`INDEX]]   <= data_in_mem;
                        end
                        else begin // write miss
                            dirty1[address[`INDEX]] <= 1;
                            mem1[address[`INDEX]]   <= mask & data_in_cpu;
                        end
                    end
                    // if all valid, find least recent use
                    // check way 2
                    else if (lru2[address[`INDEX]] == 0) begin
                        // if dirty, write back to memory
                        if (dirty2[address[`INDEX]] == 1) begin
                            m_wr_address <= {tag2[address[`INDEX]],address[`INDEX],2'b0};
                            mwren        <= 1;
                            data2mem     <= mem2[address[`INDEX]];
                        end
                        // write allocate
                        tag2[address[`INDEX]]   <= address[`TAG];
                        valid2[address[`INDEX]] <= 1;
                        lru1[address[`INDEX]]   <= 0;
                        lru2[address[`INDEX]]   <= 1;
                        if (rd) begin // read miss
                            dirty2[address[`INDEX]] <= 0;
                            mem2[address[`INDEX]]   <= data_in_mem;
                        end
                        else begin // write miss
                            dirty2[address[`INDEX]] <= 1;
                            mem2[address[`INDEX]]   <= mask & data_in_cpu;
                        end
                    end
                    else begin
                    end
                end
                DONE:begin
                    mwren    <= 0;
                    data2cpu <= 0;
                end
            endcase
        end
    end
endmodule