
`include "C:\Xilinx\Vivado\projects\cpu_riscV\miriscv_defines.v"

module ALU #(parameter N = 32, logN = 5) (
    input logic [N - 1:0] A, B,
    input logic [`ALU_OP_WIDTH - 1:0] ALUOp,
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
      `ALU_ADD: {c_out, Result} = A + B;
      `ALU_SUB: {c_out, Result} = A - B;
      `ALU_SLL: Result = A << B[logN - 1:0];
      `ALU_LTS: Result = ($signed(A) < $signed(B))? 1 : 0;
      `ALU_LTU: Result = (A < B)? 1 : 0;
      `ALU_XOR: Result = A ^ B;
      `ALU_SRL: Result = A >> B[logN - 1:0];
      `ALU_SRA: Result = $signed(A) >>> B[logN - 1:0];
      `ALU_OR : Result = A | B;
      `ALU_AND: Result = A & B;
    // FLAG operations:
      `ALU_EQ : Flag = (A == B) ? 1'b1 : 1'b0;
      `ALU_NE : Flag = (A != B) ? 1'b1 : 1'b0;
      `ALU_LTS: Flag = ($signed(A) < $signed(B))? 1 : 0;
      `ALU_GES: Flag = ($signed(A) >= $signed(B))? 1 : 0;
      `ALU_LTU: Flag = (A < B)? 1 : 0;
      `ALU_GEU: Flag = (A >= B)? 1 : 0;
      default: c_out = 1;
    endcase
end

endmodule
