`include "C:\Xilinx\Vivado\projects\cpu_riscV\miriscv_defines.v"

module LSU(
    input logic clk_i,
    //input logic arstn_i,
    
    //core protocol
    input logic  [31:0] lsu_adr_i, // +
    input logic         lsu_we_i, // +
    input logic  [2:0]  lsu_size_i,
    input logic  [31:0] lsu_data_i, // +
    input logic         lsu_req_i, // +
    output logic        lsu_stall_req_o,
    output logic [31:0] lsu_data_o, // +
    
    //memory protocol
    input logic  [31:0] data_rdata_i, // +
    output logic        data_req_o, // +
    output logic        data_we_o, // +
    output logic [3:0]  data_be_o, 
    output logic [31:0] data_adr_o, // +
    output logic [31:0] data_wdata_o // +
);

logic [5:0] count;
logic [1:0] byte_offset;

assign byte_offset = lsu_adr_i[1:0];
assign data_wdata_o = (lsu_we_i && data_req_o) ? lsu_data_i : 32'hx;
assign data_adr_o = (lsu_stall_req_o)? {lsu_adr_i[31:2], 2'b00} : 32'hx;
assign data_req_o = lsu_stall_req_o;
assign lsu_data_o = data_rdata_i;
assign data_we_o = lsu_we_i;
assign lsu_stall_req_o = (count % 2)? 1'b1 : 1'b0;

initial 
begin
    //lsu_stall_req_o <= 0;
    count <= 0;
end

always @(posedge lsu_req_i)
begin
    count <= 1;
end

always @(negedge lsu_req_i)
begin
    count <= 0;
end

always @(posedge clk_i)
begin
    if(lsu_req_i)
        count <= count + 1'b1;
    else
        count <= 0;
end

always_comb
begin
   case(lsu_size_i)
    `LDST_B: 
        case(byte_offset)
        2'b00:data_be_o <= 4'b0001;
        2'b01:data_be_o <= 4'b0010;
        2'b10:data_be_o <= 4'b0100;
        2'b11:data_be_o <= 4'b1000;
        endcase
    `LDST_H: 
        case(byte_offset[1])
        1'b0:data_be_o <= 4'b0011;
        1'b1:data_be_o <= 4'b1100;
        endcase
    `LDST_BU: 
        case(byte_offset)
        2'b00:data_be_o <= 4'b0001;
        2'b01:data_be_o <= 4'b0010;
        2'b10:data_be_o <= 4'b0100;
        2'b11:data_be_o <= 4'b1000;
        endcase
    `LDST_HU:  
        case(byte_offset[1])
        1'b0:data_be_o <= 4'b0011;
        1'b1:data_be_o <= 4'b1100;
        endcase
    `LDST_W: data_be_o = 4'b1111;
    default: data_be_o = 4'bxxxx;
    endcase 
end

always @*//(posedge clk_i)
begin
    if(lsu_req_i && (count % 2 == 0))
    case(lsu_size_i)
    `LDST_B: 
            case(lsu_adr_i[1:0])
            2'b00: lsu_data_o <= {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
            2'b01: lsu_data_o <= {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
            2'b10: lsu_data_o <= {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
            2'b11: lsu_data_o <= {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
            endcase
            
    `LDST_H: 
            case(lsu_adr_i[1:0])
            2'b00: lsu_data_o <= {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
            2'b10: lsu_data_o <= {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
            default: lsu_data_o <= 32'h0;
            endcase

    `LDST_BU:  
            case(lsu_adr_i[1:0])
            2'b00: lsu_data_o <= {24'b0, data_rdata_i[7:0]};
            2'b01: lsu_data_o <= {24'b0, data_rdata_i[15:8]};
            2'b10: lsu_data_o <= {24'b0, data_rdata_i[23:16]};
            2'b11: lsu_data_o <= {24'b0, data_rdata_i[31:24]};
            endcase
            
    `LDST_HU:  
            case(lsu_adr_i[1:0])
            2'b00: lsu_data_o <= {16'b0, data_rdata_i[15:0]};
            2'b10: lsu_data_o <= {16'b0, data_rdata_i[31:16]};
            default: lsu_data_o <= 32'hx;
            endcase
            
    `LDST_W: lsu_data_o <= data_rdata_i;
            
    default: lsu_data_o <= 32'hx;
    endcase
    else lsu_data_o <= 32'hx;
end

endmodule
