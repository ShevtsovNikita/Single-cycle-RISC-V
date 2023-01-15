module Turn_HEX(
  input  logic       CLK100MHZ,
  input  logic [7:0] data,
  output logic [7:0] HEX,
  output logic [7:0] AN
    );

logic [7:0] buffer_1, buffer_0;
logic [31:0] count;
logic [1:0] shift_reg;

assign AN = {6'b111111, ~shift_reg};

initial
begin
  HEX = 8'b11111111;
  shift_reg = 2'b01;
  count = 32'b0;
end

always @(posedge CLK100MHZ)
begin
  count <= count + 32'b1;
end
    
wire enable = (count [12:0] == 13'b0);

always @(posedge CLK100MHZ)
begin
  
  if (enable)
    shift_reg <= ~shift_reg;

  case(shift_reg)
  2'b01: HEX = buffer_0;
  2'b10: HEX = buffer_1;
  default: HEX = 8'b11111111;
  endcase
  
  count = count + 1;
  
end

always_comb
begin
  case(data[7:4])
    4'b0000: buffer_1 <= 8'b11000000;  // 0
    4'b0001: buffer_1 <= 8'b11111001;  // 1
    4'b0010: buffer_1 <= 8'b10100100;  // 2
    4'b0011: buffer_1 <= 8'b10110000;  // 3
    4'b0100: buffer_1 <= 8'b10011001;  // 4
    4'b0101: buffer_1 <= 8'b10010010;  // 5
    4'b0110: buffer_1 <= 8'b10000010;  // 6
    4'b0111: buffer_1 <= 8'b11111000;  // 7
    4'b1000: buffer_1 <= 8'b10000000;  // 8
    4'b1001: buffer_1 <= 8'b10010000;  // 9
    4'b1010: buffer_1 <= 8'b10001000;  // A
    4'b1011: buffer_1 <= 8'b10000011;  // b
    4'b1100: buffer_1 <= 8'b11000110;  // C
    4'b1101: buffer_1 <= 8'b10100001;  // d
    4'b1110: buffer_1 <= 8'b10000110;  // E
    4'b1111: buffer_1 <= 8'b10001110;  // F
  endcase
  case(data[3:0])
    4'b0000: buffer_0 <= 8'b11000000;  // 0
    4'b0001: buffer_0 <= 8'b11111001;  // 1
    4'b0010: buffer_0 <= 8'b10100100;  // 2
    4'b0011: buffer_0 <= 8'b10110000;  // 3
    4'b0100: buffer_0 <= 8'b10011001;  // 4
    4'b0101: buffer_0 <= 8'b10010010;  // 5
    4'b0110: buffer_0 <= 8'b10000010;  // 6
    4'b0111: buffer_0 <= 8'b11111000;  // 7
    4'b1000: buffer_0 <= 8'b10000000;  // 8
    4'b1001: buffer_0 <= 8'b10010000;  // 9
    4'b1010: buffer_0 <= 8'b10001000;  // A
    4'b1011: buffer_0 <= 8'b10000011;  // b
    4'b1100: buffer_0 <= 8'b11000110;  // C
    4'b1101: buffer_0 <= 8'b10100001;  // d
    4'b1110: buffer_0 <= 8'b10000110;  // E
    4'b1111: buffer_0 <= 8'b10001110;  // F
  endcase
end

endmodule
