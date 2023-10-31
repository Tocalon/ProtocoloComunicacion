`include "Tarea4_prueba.v"
`include "Tarea4_2Prueba.v"
`include "Probador_Tarea4.v"

module I2C_tesbench;

wire	CLK, RESET, START_STB, RNW, SCL, SDA_OUT, SDA_OE, SDA_IN;

wire [6:0]	sl_I2C_ADDR, ms_I2C_ADDR;	

wire [15:0]	sl_RD_DATA,	sl_WR_DATA,	ms_RD_DATA,	ms_WR_DATA;

initial begin
	$dumpfile("Salida_Tarea4.vcd");
    $dumpvars(-1, F1);
    $dumpvars(-1, C11);
	$dumpvars(-1, TXT);
end


i2c_transmitter F1 (
		.CLK (CLK),
		.RESET (RESET),
		.START_STB (START_STB),
		.RNW (RNW),
		.I2C_ADDR (ms_I2C_ADDR),
		.SCL (SCL),
		.SDA_OUT (SDA_OUT),
		.SDA_OE (SDA_OE),
		.SDA_IN (SDA_IN),
		.WR_DATA (ms_WR_DATA),
		.RD_DATA (ms_RD_DATA)
);

i2c_receiver C11 (
		.CLK (CLK),
		.RESET (RESET),
		.I2C_ADDR (sl_I2C_ADDR),
		.SCL (SCL),
		.SDA_OUT (SDA_OUT),
		.SDA_OE (SDA_OE),
		.SDA_IN (SDA_IN),
		.WR_DATA (sl_WR_DATA),
		.RD_DATA (sl_RD_DATA)
);

tester TXT (
	.CLK (CLK),
	.RESET (RESET),
	.START_STB (START_STB),
	.RNW (RNW),
	.ms_I2C_ADDR (ms_I2C_ADDR),
	.sl_I2C_ADDR (sl_I2C_ADDR),
	.SCL (SCL),
	.SDA_OUT (SDA_OUT),
	.SDA_OE (SDA_OE),
	.SDA_IN (SDA_IN),
	.ms_WR_DATA (ms_WR_DATA),
	.sl_WR_DATA (sl_WR_DATA),
	.ms_RD_DATA (ms_RD_DATA),
	.sl_RD_DATA (sl_RD_DATA)
);

endmodule
