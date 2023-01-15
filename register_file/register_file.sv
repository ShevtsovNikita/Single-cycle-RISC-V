module register_file(
    input logic WE3, clock,
    input logic [4:0] A1, A2, A3,
    input logic [31:0] WD3,
    output logic [31:0] RD1, RD2
    );

logic [31:0] x[0:31];

logic [31:0] t[0:6]; // временные регистры x[5-7], x[28-31]
logic [31:0] a[0:7]; // аргументы для функций x[10-17]
logic [31:0] s[0:11]; // оберегаемые регистры x[8-9], x[18-27]
logic [31:0] ra, sp, gp, tp, zero;

assign t[0:6] = {x[5:7], x[28:31]};
assign a[0:7] = x[10:17];
assign s[0:11] = {x[8:9], x[18:27]};
assign zero = x[0];
assign ra = x[1]; // return adres
assign sp = x[2]; // stack pointer
assign gp = x[3]; // global pointer
assign tp = x[4]; // thread pointer

assign RD1 = x[A1];
assign RD2 = x[A2];
assign x[0] = 32'b0;

always @(posedge clock)
  if(WE3 &&  A3 != 5'b0) 
    x[A3] <= WD3;

endmodule
