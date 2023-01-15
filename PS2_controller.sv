module PS2_controller(
	input  logic        CLK100MHZ,
	input  logic        [9:0] SW,
	
	input  logic        PS2_DATA,
	input  logic        PS2_CLK,
	
	output logic [7:0]  key_data
);

typedef enum logic [1:0] {IDLE = 2'b00,
                          RECIEVE_DATA = 2'b01,
                          CHECK = 2'b10} statetype;

statetype state;

//logic [9:0] ps2_clk_detect;
logic [8:0] shift_reg;
logic [3:0] count_bit;
logic areset, valid_data;

assign areset = SW[0];
assign key_data = shift_reg[7:0];

initial
begin
  count_bit = 4'b0;
  state = IDLE;
  shift_reg = 9'b0;
end

always @(posedge PS2_CLK)
begin
  if(areset)
  begin

    valid_data <= 1'b0;
    count_bit <= 4'b0;
    shift_reg <= 9'b0;
  end
  else
    begin
      if(PS2_DATA && ~(^shift_reg[7:1]) == shift_reg[8] && state == CHECK)
        valid_data <= 1'b1;
      else 
		  valid_data <= 1'b0;
      
      if(state == RECIEVE_DATA)
        begin
          count_bit <= count_bit + 1;
          shift_reg <= {PS2_DATA, shift_reg[8:1]};
        end
        else begin
          count_bit <= 4'b0; 
        end
    end
end 

//основной автомат состояний:
always @(posedge PS2_CLK)
begin
  if(areset)
    state <= IDLE;
  else
    case(state)
    IDLE: 
      if(!PS2_DATA)
        state = RECIEVE_DATA;
    
    RECIEVE_DATA:
      if(count_bit == 8)
        state = CHECK;
    
    CHECK: 
	   if(PS2_DATA)
		  begin
            state = IDLE;
		  end
    
    default: state = IDLE;
    endcase
end

endmodule 
