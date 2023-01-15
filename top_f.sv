module top_f #(parameter RAM_SIZE = 2048, parameter RAM_INIT_FILE = "")(
  // для ввода-вывода:
  input logic CLK100MHZ, PS2_CLK, PS2_DATA,
  input logic [9:0] SW,
  output logic [7:0] HEX, AN
);
  logic clk_i, rst_n_i;
  assign clk_i = CLK100MHZ;
  assign rst_n_i = SW[0];
  logic [31:0] int_req, int_fin;
//for Memory
  logic  [31:0]  instr_rdata;
  logic  [31:0]  instr_adr;
  
  logic          data_req;
  logic          data_we;
  logic  [3:0]   data_be;
  logic  [31:0]  data_rdata;
  logic  [31:0]  data_adr;
  logic  [31:0]  data_wdata;

  logic  data_mem_valid, data_rdata_core, data_req_ram, req_m, we_m, req_d0, we_d1;
  
  assign data_mem_valid   = (data_adr < RAM_SIZE) ?  1'b1 : 1'b0;
  assign data_rdata_core  = (data_mem_valid) ? data_rdata : 1'b0;
  assign data_req_ram     = (data_mem_valid) ? data_req : 1'b0;
  
//for Interrupt_Controller
  logic INT_, INT_RST;
  logic [31:0] mie, mcause;

//for PS/2 keyboard
  logic [7:0] key_data;

PS2_controller ps2 (
                   (CLK100MHZ   ),
                   (SW          ),
                   (PS2_DATA    ),
                   (PS2_CLK     ),
                   (key_data    )
);

Turn_HEX hex (
                   (CLK100MHZ   ),
                   (key_data    ),
                   (HEX         ),
                   (AN          )
);

Address_decoder AD(
                   (data_adr    ),
                   (data_req    ),
                   (data_we     ),
                   (we_m        ),
                   (req_m       ),
                   (req_d0      ),
                   (we_d1       )
);
cpu_main cpu(
    .clk_i         (clk_i       ),
    .arstn_i       (rst_n_i     ),

    .instr         (instr_rdata ),
    .PC            (instr_adr   ),

    .data_rdata_i  (data_rdata  ),
    .data_req_o    (data_req    ),
    .data_we_o     (data_we     ),
    .data_be_o     (data_be     ),
    .data_adr_o    (data_adr    ),
    .data_wdata_o  (data_wdata  ),
    
    .INT_           (INT_       ),
    .INT_RST        (INT_RST    ),
    .mie            (mie        ),
    .mcause         (mcause     )
);

RAM RAM(
    .clk_i          (clk_i      ),
    .rst_n_i        (rst_n_i    ),

    .instr_rdata_o (instr_rdata ),
    .instr_adr_i   (instr_adr   ),

    .data_rdata_o  (data_rdata  ),
    .data_req_i    (req_m       ),
    .data_we_i     (we_m        ),
    .data_be_i     (data_be     ),
    .data_adr_i    (data_adr    ),
    .data_wdata_i  (data_wdata  )
 );

Interrupt_Controller IC(
    .clock          (clk_i      ),
    .INT_           (INT_       ),
    .INT_RST        (INT_RST    ),
    .mie            (mie        ),
    .mcause         (mcause     ),
    .int_req        (int_req    ),
    .int_fin        (int_fin    )
);

endmodule
