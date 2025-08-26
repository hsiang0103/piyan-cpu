module LD_Filter (input wire [2:0] func3,
                  input wire [31:0] ld_data,
                  output reg [31:0] ld_data_f);
    
    parameter lb  = 3'b000;
    parameter lh  = 3'b001;
    parameter lw  = 3'b010;
    parameter lbu = 3'b100;
    parameter lhu = 3'b101;
    
    always @(func3 or ld_data) begin
        case(func3)
            lb:     ld_data_f = {{24{ld_data[7]}} , ld_data[7:0]};
            lbu:    ld_data_f = {{24{1'b0}} , ld_data[7:0]};
            lw:     ld_data_f = ld_data;
            lh:     ld_data_f = {{16{ld_data[15]}} , ld_data[15:0]};
            lhu:    ld_data_f = {{16{1'b0}} , ld_data[15:0]};
            default:ld_data_f = 32'h0;
        endcase
    end
endmodule
