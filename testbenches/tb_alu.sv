`timescale 1ns / 1ps

module tb_alu#(parameter N = 4, logN = 2) (); // тестирую программу с укороченными операндами, чтобы было читабельнее 
    logic [N - 1:0] a, b, result, result_expected;
    logic [17:0] testvectors [32:0];
    logic [32:0] vectornum, errors;
    logic [4:0] aluop;
    logic clock, flag, flag_expected;
  
alu dut(.A(a), .B(b), .ALUOp(aluop), .Result(result), .Flag(flag));

always
begin
    clock = 0; #5; // задаю тактирование 
    clock = 1; #5;
end

initial
begin
    $readmemb("testvectors.tv", testvectors); // считываю тестовые векторы из файла памяти в массив
    vectornum = 0; 
    errors = 0; // тут будет храниться количество ошибок
end

always @(posedge clock)
begin
    #1; {a, b, aluop, result_expected, flag_expected} = testvectors[vectornum]; // считываем тестовый вектор из массива
    vectornum = vectornum + 1;
end

always @(negedge clock)
begin
    if(result != result_expected)// если возникла ошибка, то программа выводит в консоль информацию об этом
        begin
            $display("Error in line %d", vectornum); 
            errors = errors + 1;
        end
    if(testvectors[vectornum] === 18'bx) // когда тестовые векторы кончились - завершаем симуляцию
        begin
            $display("%d errors total", errors);
            $finish;
        end
end

endmodule
