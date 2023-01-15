
`include "C:\Xilinx\Vivado\projects\cpu_riscV\miriscv_defines.v"

module main_decoder(
    input  logic [31:0] fetched_instr,
    input  logic stall, INT_,
    output logic [1:0] src_A, // выбор операнда А
    output logic [2:0] src_B, // выбор операнда В
    output logic [4:0] ALUOp, // операция АЛУ
    output logic mem_req, // запрос на доступ к памяти
    output logic mem_we, // разрешение записи в память данных
    output logic [2:0] mem_size, // выбор размера слова из памяти
    output logic gpr_we_a, // разрешение записи в регистровый файл
    output logic wb_src_sel, // выбор данных записываемых в регистровый файл
    output logic illegal_instr, // сигнал о некорректной интсрукции 
    output logic branch, // инструкция условного перехода
    output logic jal, // инструкция безусловного перехода jalr
    output logic [1:0] jalr, // инструкция безусловного перехода jal
    output logic [2:0] CSROp,
    output logic enpc, csr, INT_RST
);

wire [6:0] opcode;
wire [2:0] func3;
wire [6:0] func7;

assign enpc = ~stall;

assign opcode = fetched_instr[6:0];
assign func7 = fetched_instr[31:25];
assign func3 = fetched_instr[14:12];


always_comb
begin
if(INT_)
    begin
      CSROp[2] = 1;
      jalr = 2'b11;
      
    end
    else begin
CSROp[2] = 0;
illegal_instr <= 0;
mem_size <= 3'bxxx;
    if (opcode[1:0] != 2'b11)
        begin
                  illegal_instr <= 1;
                  mem_size <= 3'bxxx;
                end
    else
    
    case (opcode [6:2]) 
      `LOAD_OPCODE: // LOAD (I): rd = Mem[rs1 + imm] (+)
        begin
          src_A <= 0; // операнд А считываем из регистрового файла
          src_B <= 1; // операнд B считываем как константу с расширением знака
          ALUOp <= `ALU_ADD; // выполняем сложение rs1 и imm
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 1; // результат операции записываем в регистровый файл из памяти
          mem_req <= 1; // обращаемся к памяти (чтение)
          mem_we <= 0; // в память ничего не записываем 
            case(func3) // параметры memi
              3'b000: mem_size <= `LDST_B;
              3'b001: mem_size <= `LDST_H;
              3'b010: mem_size <= `LDST_W;
              3'b100: mem_size <= `LDST_BU;
              3'b101: mem_size <= `LDST_HU;
              default: 
                begin
                  illegal_instr <= 1;
                  mem_size <= 3'bxxx;
                end 
             endcase
          jal <= 0; jalr <= 2'b00; branch <= 0; csr <= 0; INT_RST = 0;
        end
        
      `MISC_MEM_OPCODE: // MISC_MEM
        begin
                  illegal_instr <= 0;
                  gpr_we_a <= 0;
                  mem_req <= 0;
                  mem_size <= 3'bxxx;
                  csr <= 0; INT_RST = 0;
                end
        
      `OP_IMM_OPCODE: // OP_IMM (I): rd = alu_op (rs1, imm) (+)
        begin
          src_A <= 0; // операнд А считываем из регистрового файла
          src_B <= 1; // операнд B считываем как константу с расширением знака
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл из АЛУ
          mem_we <= 0; // в память ничего не записываем
          mem_req <= 0; // к памяти не обращаемся
          mem_size <= 3'bxxx;
            case(func3) 
             3'b000: ALUOp <= `ALU_ADD; // +
             3'b100: ALUOp <= `ALU_XOR; // xor
             3'b110: ALUOp <= `ALU_OR; // or
             3'b111: ALUOp <= `ALU_AND; // and
             3'b001: 
                begin
                if(func7 == 7'b0000000)
                    ALUOp <= `ALU_SLL;
                else
                     begin
                        illegal_instr <= 1;
                      gpr_we_a <= 0;
                     end end
             3'b101: 
             begin
                if(func7 == 7'b0000000)
                    ALUOp <= `ALU_SRL; //>>
                 else
                    if(func7 == 7'b0100000)
                       ALUOp <= `ALU_SRA; // >>>
                     else begin
                     illegal_instr <= 1;
                      gpr_we_a <= 0;
                     end
             end
             3'b010: ALUOp <= `ALU_LTS; // signed(A < B)
             3'b011: ALUOp <= `ALU_LTU; // (A < B)
             default: 
             begin
                illegal_instr <= 1;
                gpr_we_a <= 0;
             end
            endcase
          jal <= 0; jalr <= 2'b00; branch <= 0;  csr <= 0; INT_RST = 0;
        end
        
      `AUIPC_OPCODE: // AUPIC (U): rd = PC + (imm << 12) (+)
        begin
          src_A <= 1; // в качестве операнда А берем значение РС
          src_B <= 2; // операнд B считываем как константу с расширением знака
          ALUOp <= `ALU_ADD; // выполняем сложение РС и imm_I
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл из АЛУ
          mem_we <= 0; // в память ничего не записываем
          mem_req <= 0; // к памяти не обращаемся
          mem_size <= 3'bxxx;
          jal <= 0; jalr <= 2'b00; branch <= 0;  csr <= 0; INT_RST = 0;
        end 
        
      `STORE_OPCODE: // STORE(S): Mem[rs1 + imm] = rs2  (+)
        begin
          src_A <= 0; // операнд А считываем из регистрового файла
          src_B <= 3; // операнд B считываем как константу S с расширением знака
          gpr_we_a <= 0; // результат операции НЕ записываем в регистровый файл
          ALUOp <= `ALU_ADD; // выполняем сложение rs1 и imm
          mem_req <= 1; // обращаемся к памяти
          mem_we <= 1; // запись в память значение rs2
            case(func3) // параметры memi
              3'b000: mem_size <= 3'b000;
              3'b001: mem_size <= 3'b001;
              3'b010: mem_size <= 3'b010;
              default: 
                begin
                  illegal_instr <= 1;
                  mem_size <= 3'bxxx;
                end
            endcase
          jal <= 0; jalr <= 0; branch <= 0;  csr <= 0; INT_RST = 0;
        end 
        
      `OP_OPCODE: // OP (R): rd = alu_op (rs1, rs2)
        begin
          src_A <= 0; // операнд А считываем из регистрового файла
          src_B <= 0; // операнд B считываем из регистрового файла
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл из АЛУ
          mem_req <= 0; // к памяти не обращаемся
          mem_size <= 3'bxxx;
          mem_we <= 0; // в память ничего не записываем 
          if(func7 != 7'h20 && func7 !=7'h00)
          begin
                illegal_instr <= 1;
                gpr_we_a <= 1'b0;
                end
                
             case({func3, func7[5:4]}) // выбор операции АЛУ
               5'b000_00: ALUOp <= `ALU_ADD; // +
               5'b000_10: ALUOp <= `ALU_SUB; // -
               5'b100_00: ALUOp <= `ALU_XOR; // xor
               5'b110_00: ALUOp <= `ALU_OR; // or
               5'b111_00: ALUOp <= `ALU_AND; // and
               5'b001_00: ALUOp <= `ALU_SLL; // <<
               5'b101_00: ALUOp <= `ALU_SRL; // >>
               5'b101_10: ALUOp <= `ALU_SRA; // >>> 
               5'b010_00: ALUOp <= `ALU_LTS; // signed(A < B)
               5'b011_00: ALUOp <= `ALU_LTU; // (A < B)
               default: 
                begin
                illegal_instr <= 1;
                gpr_we_a <= 1'b0;
                end
             endcase
          jal <= 0; jalr <= 2'b00; branch <= 0;  csr <= 0; INT_RST = 0;
        end
        
      `LUI_OPCODE: // LUI (U): rd = imm <<< 12 (+)
        begin
          src_A <= 2; // в качестве операнда А берем значение 0
          src_B <= 2; // операнд B считываем как константу с расширением знака
          ALUOp <= `ALU_ADD; // выполняем сложение 0 и imm_I
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл из АЛУ
          mem_req <= 0; // к памяти не обращаемся 
          mem_size <= 3'bxxx;
          mem_we <= 0; // в память ничего не записываем 
          jal <= 0; jalr <= 2'b00; branch <= 0;  csr <= 0; INT_RST = 0;
        end
        
      `BRANCH_OPCODE: // BRANCH (B): if alu_op(rs1, rs2): PC += imm (+)
        begin
          src_A <= 0; // операнд А считываем из регистрового файла
          src_B <= 0; // операнд B считываем из регистрового файла
          gpr_we_a <= 0; // результат операции НЕ записываем в регистровый файл
          wb_src_sel <= 1'bx; // результат операции записываем в регистровый файл из АЛУ
          mem_req <= 0; // к памяти не обращаемся 
          mem_size <= 3'bxxx;
             case(func3) // выбор операции АЛУ
               3'b000: ALUOp <= `ALU_EQ; // ==
               3'b001: ALUOp <= `ALU_NE; // !=
               3'b100: ALUOp <= `ALU_LTS; // < s
               3'b101: ALUOp <= `ALU_GES; // >= s
               3'b110: ALUOp <= `ALU_LTU; // < u
               3'b111: ALUOp <= `ALU_GEU; // >= u
               default: illegal_instr <= 1;
             endcase
          branch <= 1; // PC = (comp)? PC + imm : PC + 4; 
          jal <= 0; jalr <= 2'b00; csr <= 0; INT_RST = 0;
          
        end
        
      `JALR_OPCODE: // JALR(J): rd = PC + 4; PC = rs1 (+)
       if(func3 == 3'b000)  begin
          src_A <= 1; // в качестве операнда А берем значение РС
          src_B <= 4; // в качестве операнда А берем значение 4
          ALUOp <= `ALU_ADD; // выполняем сложение РС + 4
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл из АЛУ
          mem_req <= 0; // к памяти не обращаемся
          mem_size <= 3'bxxx;
          mem_we <= 0; // в память ничего не записываем 
          jalr <= 2'b01; // PC = rs1 
          jal <= 0; branch <= 0; csr <= 0; INT_RST = 0;
        end
        else
        begin
            illegal_instr <= 1;
            jalr <= 2'b00;
            gpr_we_a <= 0;
            csr <= 0;
            INT_RST = 0;
        end
        
      `JAL_OPCODE: // JAL (J): rd = PC + 4; PC += imm (+)
        begin
          src_A <= 1; // в качестве операнда А берем значение РС
          src_B <= 4; // в качестве операнда А берем значение 4
          ALUOp <= `ALU_ADD; // выполняем сложение РС + 4
          gpr_we_a <= 1; // результат операции записываем в регистровый файл
          wb_src_sel <= 0; // результат операции записываем в регистровый файл
          mem_req <= 0; // к памяти не обращаемся 
          mem_size <= 3'bxxx;
          mem_we <= 0; // в память ничего не записываем 
          jal <= 1; // PC = PC + imm
          jalr <= 2'b00; branch <= 0; csr <= 0; INT_RST = 0;
        end
        
      `SYSTEM_OPCODE: // SYSTEM 
        begin
        mem_req <= 1'b0;
          case(func3)
          3'b000: // PC = mepc
            begin
              CSROp[1:0] = 2'b00;
              jalr = 2'b10; 
              INT_RST = 1; // прерывание обработано
            end
          3'b001: //rd = csr; csr = rs1
            begin
              CSROp[1:0] = 2'b01;
              gpr_we_a <= 1'b1;
              jalr = 2'b00;
              INT_RST = 0;
              csr <= 1;
            end
          3'b010: //rd = csr; csr = csr | rs1
            begin
              CSROp[1:0] = 2'b11;
              gpr_we_a <= 1'b1;
              jalr = 2'b00;
              INT_RST = 0;
              csr <= 1;
            end
          3'b011: //rd = csr; csr = csr & ~rs1
            begin
              CSROp[1:0] = 2'b10;
              gpr_we_a <= 1'b1;
              jalr = 2'b00;
              INT_RST = 0;
              csr <= 1;
            end
            default: CSROp[1:0] = 2'b00;
          endcase
          illegal_instr <= 0;
          jal <= 0;
        end
        
      default: begin
                  illegal_instr <= 1;
                  mem_size <= 3'bxxx;
                end
      
      endcase
end

end
endmodule
