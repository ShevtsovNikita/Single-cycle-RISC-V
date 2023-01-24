module alu #(parameter N = 4, logN = 2) (
    input logic [N - 1:0] A, B,
    input logic [4:0] ALUOp,
    output logic [N - 1:0] Result,
    output logic Flag
    );
    
logic c_out;

always_comb
begin

    if(ALUOp[4])
        Result = 0;
    else 
        Flag = 0;
        
    case(ALUOp)
    // RESULT operations:
      5'b00000: {c_out, Result} = A + B;
      5'b01000: {c_out, Result} = A - B;
      5'b00001: Result = A << B[logN - 1:0];
      5'b11100: Result = ($signed(A) < $signed(B))? 1 : 0;
      5'b11110: Result = (A < B)? 1 : 0;
      5'b00100: Result = A ^ B;
      5'b00101: Result = A >> B[logN - 1:0];
      5'b01101: Result = $signed(A) >>> B[logN - 1:0];
      5'b00110: Result = A | B;
      5'b00111: Result = A & B;
    // FLAG operations:
      5'b11000: Flag = (A == B) ? 1'b1 : 1'b0;
      5'b11001: Flag = (A != B) ? 1'b1 : 1'b0;
      5'b11100: Flag = ($signed(A) < $signed(B))? 1 : 0;
      5'b11101: Flag = ($signed(A) >= $signed(B))? 1 : 0;
      5'b11110: Flag = (A < B)? 1 : 0;
      5'b11111: Flag = (A >= B)? 1 : 0;
      default: c_out = 1;
    endcase
end

endmodule
