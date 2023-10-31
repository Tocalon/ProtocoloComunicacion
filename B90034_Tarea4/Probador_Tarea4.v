// Actual test code for the adder module
module tester(CLK, RESET, START_STB, RNW, ms_I2C_ADDR,sl_I2C_ADDR, SCL, SDA_OUT, SDA_OE, SDA_IN, ms_WR_DATA,	sl_WR_DATA,	ms_RD_DATA,	sl_RD_DATA);

output reg CLK, RESET, RNW, START_STB ;
input wire SCL, SDA_OUT, SDA_IN,  SDA_OE;
output reg [6:0] ms_I2C_ADDR,sl_I2C_ADDR;
input  wire [15:0] sl_WR_DATA, ms_RD_DATA; 
output reg [15:0] sl_RD_DATA,  ms_WR_DATA;

parameter h_freq=20;

always begin
	#h_freq CLK = !CLK;
end


initial begin
 	#0	CLK		=	0;
		RESET		=	1;
    #10 RESET = 0; 
		START_STB	=	0;
		RNW		=	1;
		sl_RD_DATA	=	0;
		ms_WR_DATA	=	0;
		ms_I2C_ADDR	=	26;
		sl_I2C_ADDR	=	26;
	#20	RESET		=	1;
	#10	START_STB	=	1;

	#900	START_STB	=	0;

    #100 RESET=0;
    #10	CLK		=	0;
		RESET		=	1;
		START_STB	=	0;
		RNW		=	1;
		sl_RD_DATA	=	0;
		ms_WR_DATA	=	0;
		ms_I2C_ADDR = 32'hB90034;
		ms_I2C_ADDR = 32'hB90034;
	#20	RESET		=	0;
	#10	START_STB	=	1;

    #900	START_STB	=	0;

	#100	$finish;
end


endmodule
