`include "C:\Xilinx\Vivado\projects\cpu_riscV\miriscv_defines.v"

module cpu_main(
    //common
    input   logic          clk_i,
    input   logic          arstn_i,
    
    //memory
    input   logic  [31:0]  instr,
    input   logic  [31:0]  data_rdata_i,
    output  logic  [31:0]  PC,
    output  logic          data_req_o,
    output  logic          data_we_o, 
    output  logic  [3:0]   data_be_o,   
    output  logic  [31:0]  data_adr_o,
    output  logic  [31:0]  data_wdata_o,
    
    //interrupt controller
    input   logic          INT_, 
    input   logic  [31:0]  mcause,
    output  logic          INT_RST,
    output  logic  [31:0]  mie
    );


logic comp, rf_we, mem_we, enpc, jal, branch, ws, mem_req, illegal_instr, stall, csr;
logic [3:0] memi;
logic [1:0] src_a, jalr;
logic [2:0] src_b, mem_size, CSROp;
logic [4:0] A1, A2, A3;
logic [31:0] WD, RD1, RD2, RD, WD3, A, B, alu_result, rfw_mut, mepc, mtvec, csr_RD;
logic [31:0] imm_I, imm_S, imm_B, imm_U, imm_J;
logic [`ALU_OP_WIDTH - 1:0] aluop;


// including inner modules:
///////////////////////////////////////////////////////////////////////////////////////////////////
ALU ALU(
        .A              (A              ), 
        .B              (B              ), 
        .ALUOp          (aluop          ), 
        .Result         (alu_result     ), 
        .Flag           (comp           )
);

register_file RF(
        .WE3            (rf_we          ), 
        .A1             (A1             ), 
        .A2             (A2             ), 
        .A3             (A3             ), 
        .RD1            (RD1            ), 
        .RD2            (RD2            ), 
        .WD3            (rfw_mut        ), 
        .clock          (clk_i          )
);

LSU LSU(
        .clk_i           (clk_i         ),
        .lsu_adr_i       (alu_result    ),   
        .lsu_we_i        (mem_we        ), 
        .lsu_size_i      (mem_size      ),  
        .lsu_data_i      (RD2           ),  
        .lsu_req_i       (mem_req       ),   
        .lsu_stall_req_o (stall         ),  
        .lsu_data_o      (RD            ),  
                     
        .data_rdata_i    (data_rdata_i  ),
        .data_req_o      (data_req_o    ),
        .data_we_o       (data_we_o     ), 
        .data_be_o       (data_be_o     ),   
        .data_adr_o      (data_adr_o    ), 
        .data_wdata_o    (data_wdata_o  ));

CSR CSR(
        .clock          (clk_i          ),
        .A              (instr[31:20]   ), 
        .WD             (RD1            ), 
        .PC             (PC             ), 
        .mcause         (mcause         ), 
        .mie            (mie            ), 
        .mtvec          (mtvec          ), 
        .mepc           (mepc           ), 
        .CSROp          (CSROp          ),
        .csr_RD         (csr_RD         )
);

main_decoder main_decoder(
        .INT_           (INT_           ),
        .INT_RST        (INT_RST        ),
        .fetched_instr  (instr          ), 
        .stall          (stall          ),
        .src_A          (src_a          ), 
        .src_B          (src_b          ), 
        .ALUOp          (aluop          ), 
        .mem_req        (mem_req        ), 
        .mem_we         (mem_we         ), 
        .mem_size       (mem_size       ), 
        .gpr_we_a       (rf_we          ), 
        .wb_src_sel     (ws             ), 
        .illegal_instr  (illegal_instr  ), 
        .branch         (branch         ), 
        .jal            (jal            ), 
        .jalr           (jalr           ),
        .enpc           (enpc           ),
        .csr            (csr            ),
        .CSROp          (CSROp          )
);
///////////////////////////////////////////////////////////////////////////////////////////////////

initial
begin
    PC = 32'h00000000;
    //enpc = 1;
end


assign memi = {mem_req, mem_size};

// Sign Extentions:
assign imm_U = {instr[31:12], 12'b0};
assign imm_I = {{20{instr[31]}}, instr[31:20]};
assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
assign imm_B = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
assign imm_J = {{20{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

//adresses for Register file
assign A1 = instr[19:15];
assign A2 = instr[24:20];
assign A3 = instr[11:7];

always_comb
begin
// ALU operands muts:
    case(src_a)
      2'b00: A <= RD1;
      2'b01: A <= PC;
      2'b10: A <= 0;
    endcase
    
    case(src_b)
      3'b000: B <= RD2;
      3'b001: B <= imm_I;
      3'b010: B <= imm_U;
      3'b011: B <= imm_S;
      3'b100: B <= 4;
      endcase
      
// Register file write source
    rfw_mut <= (csr)? csr_RD : ((ws)? RD : alu_result);
    
end

// for PC
always @(posedge clk_i)
begin
    //if(enpc)
    case(jalr)
    2'b00: PC = (enpc)? ((jalr)? RD1 : (PC + ((jal || (comp && branch))? ((branch)? imm_B : imm_I ): 4))) : PC;
    2'b01: PC = (enpc)? RD1 : PC;
    2'b10: PC = (enpc)? mepc : PC;
    2'b11: PC = (enpc)? mtvec : PC;
    endcase
    
end

endmodule

