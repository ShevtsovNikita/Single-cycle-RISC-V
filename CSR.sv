module CSR(
    input  logic        clock,
    input  logic [2:0]  CSROp,
    input  logic [11:0] A,
    input  logic [31:0] PC,
    input  logic [31:0] WD,
    input  logic [31:0] mcause,
    output logic [31:0] mie,
    output logic [31:0] mtvec,
    output logic [31:0] mepc,
    output logic [31:0] csr_RD
    );
    
logic [31:0] mut, rd, mscratch, mc;
logic [2:0] OP;
assign OP = CSROp;
assign csr_RD = rd;

always_comb
begin
  case(OP[1:0])
    2'b00: mut = 32'h0;
    2'b01: mut = WD;
    2'b10: mut = WD & ~ rd;
    2'b11: mut = WD | rd;
  endcase

  case(A)
    12'h304: rd = mie;
    12'h305: rd = mtvec;
    12'h340: rd = mscratch;
    12'h341: rd = mepc;
    12'h342: rd = mc;
  endcase
end 

always @(posedge clock)
begin
  case(A)
    12'h304: mie =          (|OP[1:0])? mut : mie;
    12'h305: mtvec =        (|OP[1:0])? mut : mtvec;
    12'h340: mscratch =     (|OP[1:0])? mut : mscratch;
    12'h341: mepc =         (|OP[2:0])? (OP[2]? PC : mut) : mepc;
    12'h342: mc =           (|OP[2:0])? (OP[2]? mcause : mut) : mc;
    default:
      begin
        if(OP[2])
          begin
            mepc = PC;
            mc = mcause;
          end
      end
  endcase
end

endmodule
