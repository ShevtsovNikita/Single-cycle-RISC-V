module Interrupt_Controller(
    input  logic       clock,
    input  logic       INT_RST,
    input  logic [31:0] int_req,
    input  logic [31:0] mie,
    
    output logic        INT_,
    output logic [31:0] int_fin,
    output logic [31:0] mcause // +
    );

logic [4:0] n;
logic int_b, int_a, mut;

initial 
begin
    //int_fin = 32'h0;
    n <= 5'b0;
end

assign mcause = {27'h0000000, n};
assign INT_ = ((~INT_RST) && int_a ^ int_b === 1)? 1 : 0;

always @(posedge clock or posedge INT_RST)
if(mie !== 32'bx)
begin
    int_b <= int_a;
    
    if(INT_RST)
        n <= 5'b0;
    else
        n <= (~int_a)? n + 1 : n;
end

always_comb
begin
  int_a = int_req[n] && mie[n];
  //int_fin[n] = INT_RST & int_req[n] & mie[n];
end 

endmodule
