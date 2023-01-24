`timescale 1ns / 1ps

module tb_cpu_main();

  parameter HF_CYCLE = 5;          // 200 MHz clock

  logic rst_n, clk;

  top_f dut (.CLK100MHZ(clk));

  initial 
  begin;
    clk   = 1'b0;
    #1200;
    $finish;
  end

  always 
  begin // задаю тактирование
    #HF_CYCLE;
    clk = ~clk;
  end

endmodule
