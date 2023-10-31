module i2c_transmitter(CLK ,RESET, START_STB, RNW, I2C_ADDR, WR_DATA, SDA_IN, SCL, SDA_OUT, SDA_OE, RD_DATA); 

input wire	CLK, RESET,START_STB,RNW,SDA_IN;
input wire [15:0] WR_DATA;
input wire [6:0] I2C_ADDR;
output SCL, SDA_OUT, SDA_OE;
output reg [15:0] RD_DATA;

// Internal variable declaration
reg [1:0]	SCL_count;	// For generating the 25% frecuency of CLK
reg	 bytes_count, ACK, start_sent, SDA_OUT, SDA_OE,previous_SCL;	// For any SCL signal, this reg will have the previous one
wire SCL, posedge_SCL;	// Is 1 on every posedge of SCL
reg [23:0]	output_data;	// Data string to be sent	// Number of bytes sent, a total of 3
reg [2:0]	counter_bits;	// Number of bits sent of 1 byte, from 0 to 7
reg [15:0]	received_data;	// Data obtained from the slave device
reg [6:0]	ms_state, next_ms_state;	

// States of the fsm are declared next
localparam WAITING_START	=	7'b0000001; // Waits for START_STB to initiate a transaction
localparam STARTING_COMM	=	7'b0000010; // Sends the START signal
localparam ENDING_COMM		=	7'b0000100; // Sends the STOP signal
localparam SENDING_ACK	 	=	7'b0001000; // Answers to the slave with and ACK pulse
localparam WAITING_ACK	 	=	7'b0010000; // Waits for an ACK pulse from the slave
localparam SENDING_BYTE		=	7'b0100000; // Sends a byte serially through SDA_OUT, enables SDA_OE
localparam RECEIVING_BYTE	=	7'b1000000; // Reveives a byte serially through SDA_IN

// This cicle sets up the ms_state machine at boot, gets the I2C clock to
// work at 1/4 of the CLK frecuency and changes the current ms_state of the fsm
always @ (posedge CLK) begin
	if (RESET) begin
		SCL_count	=	0;
		previous_SCL	=	0;
		bytes_count	=	0;
		counter_bits	=	0;
		received_data	=	0;
		ACK	=	0;
		start_sent	=	0;
		SDA_OUT		=	1;	// By default, SDA is high
		SDA_OE		=	1;	// And SDA_OE is also 1 
		RD_DATA		=	0;
		ms_state		=	WAITING_START;
	end else begin

		if (SCL_count[1] & ~SCL_count[0]) begin
			SCL_count	<=	SCL_count + 1;
		end

		SCL_count	<=	SCL_count + 1;

		if (!posedge_SCL && !previous_SCL) begin
			ms_state	=	next_ms_state;
		end

		previous_SCL	<=	SCL;
	end
end

always @ (*) begin

	case (ms_state)

		WAITING_START: begin
			if (START_STB) begin
				next_ms_state = STARTING_COMM;
			end else begin
				SDA_OUT		=	1;	// By default, SDA is high
				SDA_OE		=	1;	// And SDA_OE is also 1 
				RD_DATA		=	0;
				next_ms_state 	=	WAITING_START;
			end
		end

		STARTING_COMM: begin
			if (SCL && ~SCL_count && posedge_SCL) begin
				SDA_OUT		=	1'b0;
				next_ms_state	=	SENDING_BYTE;
			end
		end

		ENDING_COMM: begin
			if (SCL && ~SCL_count) begin
				SDA_OUT		=	1'b1;
				next_ms_state		=	WAITING_START;
			end else begin
				SDA_OUT		=	1'b0;
				next_ms_state		=	ENDING_COMM;
			end

		end

		SENDING_ACK: begin
			SDA_OE		=	1;
			SDA_OUT		=	1;
			next_ms_state	=	RECEIVING_BYTE;
		end

		WAITING_ACK: begin
				SDA_OUT		=	0;
				SDA_OE		=	0;
			
				if (!SDA_IN) begin
					if (RNW) begin
						next_ms_state	=	RECEIVING_BYTE;
					end else begin
						next_ms_state	=	SENDING_BYTE;
					end
				end else if (!posedge_SCL && !previous_SCL) begin
					next_ms_state   =       ENDING_COMM;
				end

		end
		SENDING_BYTE: begin
			SDA_OE	=	1;

			if (posedge_SCL && !SCL_count) begin

			if (!ACK) begin
				if (counter_bits < 7) begin
					SDA_OUT		=	I2C_ADDR[6-counter_bits];	// Sends the slave addess
					next_ms_state	=	SENDING_BYTE;		// If the addr is not yet sent, 
				end else begin
					SDA_OUT		=	RNW;		// Sends the transaction  type
					ACK	=	1;
					counter_bits	=	0;
					next_ms_state	=	WAITING_ACK;	// Once everything for the fisrt btye
				end
			end else begin
				SDA_OUT		=	WR_DATA[counter_bits+8*bytes_count];	// Sends the data
				next_ms_state	=       SENDING_BYTE;
				if (counter_bits == 7) begin	// Once the data is sent, the ms_states goes to WAITIN_ACK
					counter_bits	=	0;
					next_ms_state	=	WAITING_ACK;
				end
			end
			counter_bits	=	counter_bits + 1;// Bits counter keeps going
			end 
		end
		RECEIVING_BYTE: begin
			SDA_OE	=	0;
			RD_DATA		=	{RD_DATA, SDA_IN};	// Sends the data
			next_ms_state      =       RECEIVING_BYTE;
			if (counter_bits == 7) begin	// Once the data is sent, the ms_states goes to WAITIN_ACK
				bytes_count	=	bytes_count + 1;
				next_ms_state	=	SENDING_ACK;
			end
		counter_bits	=	counter_bits + 1;		// Keeps the bit counter going
		end
	endcase
end

// Definition for SCL flipping  and posedge signal for SCL
assign	SCL		=	~SCL_count[1];
assign	posedge_SCL	=	SCL && ~previous_SCL;


endmodule