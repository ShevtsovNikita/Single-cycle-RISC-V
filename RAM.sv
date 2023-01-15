module RAM #( parameter RAM_SIZE = 2048, parameter RAM_INIT_FILE = "8_lab.mem")(
  input clk_i,
  input rst_n_i,

  // instruction memory interface
  output logic  [31:0]  instr_rdata_o,
  input  logic  [31:0]  instr_adr_i,

  // data memory interface
  output logic  [31:0]  data_rdata_o,
  input  logic          data_req_i,
  input  logic          data_we_i,
  input  logic  [3:0]   data_be_i,
  input  logic  [31:0]  data_adr_i,
  input  logic  [31:0]  data_wdata_i
);

logic [3:0][7:0] mem [0:RAM_SIZE/4-1];

  //Init RAM
  integer ram_index;

  initial begin
  
   // if(RAM_INIT_FILE != "")
      $readmemh("8_lab.mem", mem);
   // else
     // for (ram_index = 0; ram_index < RAM_SIZE/4 - 1; ram_index = ram_index + 1)
        //mem[ram_index] <= {32{1'b0}};
  end


  //Instruction port
 assign instr_rdata_o = mem[(instr_adr_i / 4) % RAM_SIZE];
//  always @(negedge data_req_i)
//    data_rdata_o <= (data_req_i) ? mem[(data_adr_i / 4) % RAM_SIZE] : 32'hx;
    
  always @(posedge clk_i) 
  begin
//    if(!rst_n_i) begin
//      data_rdata_o  <= 32'b0;
//    end
//    else 
    if(data_req_i == 1) 
        begin
        //
         data_rdata_o <= mem[(data_adr_i / 4) % RAM_SIZE];
         // sb
         if(data_we_i && data_be_i == 4'b0000)
           mem[data_adr_i[31:2]] [0]  <= data_wdata_i[7:0];
    
         if(data_we_i && data_be_i == 4'b0010)
           mem[data_adr_i[31:2]] [1] <= data_wdata_i[15:8];
    
         if(data_we_i && data_be_i == 4'b0100)
          mem[data_adr_i[31:2]] [2] <= data_wdata_i[23:16];

         if(data_we_i && data_be_i == 4'b1000)
          mem[data_adr_i[31:2]] [3] <= data_wdata_i[31:24];
          
         //sh
         if(data_we_i && data_be_i == 4'b0011)
          mem[data_adr_i[31:2]] [1:0]  <= data_wdata_i[15:0];
          
         if(data_we_i && data_be_i == 4'b1100)
          mem[data_adr_i[31:2]] [3:2]  <= data_wdata_i[31:16];
          
         //sw
         if(data_we_i && data_be_i == 4'b1111)
          mem[data_adr_i[31:2]] [3:0]  <= data_wdata_i[31:0];

        end
       // else data_rdata_o <= 32'hx;
  end


endmodule
