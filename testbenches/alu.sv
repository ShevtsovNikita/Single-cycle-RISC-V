module alu #(parameter N = 4, logN = 2) (
    input logic [N - 1:0] A, B,
    input logic [4:0] ALUOp,
    output logic c_out,
    output logic [N - 1:0] Result,
    output logic Flag
    );

always_comb
begin
  if(!ALUOp[4])
    begin
    Flag = 0;
    case(ALUOp[2:0])
      3'b000: 
        if(!ALUOp[3])
          {c_out, Result} = A + B;
        else  
          {c_out, Result} = A + ~B + 1;
      3'b001: Result = A << B[logN - 1:0];
      3'b010: 
        if(A[31] ^ B[31] == 1) 
          Result = (A < B)? B : A;
        else 
          if(A[31] == 0)
            Result = (A < B)? A : B;
          else
            Result = (A < B)? B : A;
      3'b011: 
        if(A > B) 
          Result = B;
        else 
          Result = A;
      3'b100: Result = A ^ B;
      3'b101: 
        if(ALUOp[3])
          Result = A >> B[logN - 1:0];
        else  
          Result = A >>> B[logN - 1:0];
      3'b110: Result = A | B;
      3'b111: Result = A & B;
      
    endcase
    end
  else
    begin
    Result = '0;
    case(ALUOp[2:0])
      3'b000: Flag = (A == B);
      3'b001: Flag = (A != B);
      3'b100: 
            if(A[N-1] ^ B[N-1])
              if(A[N-1])
                Flag = 1;
              else
                Flag = 0;
            else 
              if(A[N-1])
                if(A[N-1] > B[N-1])
                  Flag = 0;
                else 
                  Flag = 1;
              else
                if(A[N-1] > B[N-1])
                  Flag = 0;
                else
                  Flag = 1;
      3'b101: if(A[N-1] ^ B[N-1])
              if(A[N-1])
                Flag = 0;
              else
                Flag = 1;
            else 
              if(A[N-1])
                if(A[N-1] <= B[N-1])
                  Flag = 0;
                else 
                  Flag = 1;
              else
                if(A[N-1] <= B[N-1])
                  Flag = 0;
                else
                  Flag = 1;
      3'b110: Flag = (A < B);
      3'b111: Flag = (A >= B);
      default: Flag = 0;
    endcase
    end
end

endmodule


