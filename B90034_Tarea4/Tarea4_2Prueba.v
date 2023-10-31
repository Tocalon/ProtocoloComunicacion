module i2c_receiver(CLK ,RESET, RNW,  I2C_ADDR, WR_DATA, SDA_IN, SCL, SDA_OUT, SDA_OE, RD_DATA); 

// Delcaration of inputs and outputs
input wire	CLK, RESET, SCL, SDA_OUT, SDA_OE;
input wire [6:0] I2C_ADDR;
input wire [15:0] RD_DATA;
output reg	SDA_IN, RNW;
output reg [15:0] WR_DATA;

// Internal variable declaration
//reg 		SCL_count;	// For generating the 25% frecuency of CLK
reg	 previous_SCL, previous_SDA, ACK, bytes_count;	// For any SDA_OUT signal, this reg will have the previous one
reg [6:0]	slave_addr;	
wire  posedge_SCL;
reg [2:0]	bits_count;	// Number of bits sent of 1 byte, from 0 to 7
reg [6:0]	sl_state;		// Current sl_state of the fsm
reg [6:0]	next_sl_state;	// Next sl_state of the fsm


reg [4:0]	out_index;	// Index for walking output_data
reg [15:0]	received_data;	// Data obtained from the slave device

// States of the fsm are declared next
localparam WAITING_START	=	6'b000001;	// Waiting for START signal over SDA_OUT
localparam VERIFYING_ADDR	=	6'b000010;	// Verifies the ADDR received over SDA_OUT
localparam SENDING_ACK		=	6'b000100;	// Sends an ACK signal over SDA_IN
localparam WAITING_ACK		=	6'b001000;	// Waits for the master to send an ACK signal
localparam SENDING_BYTE		=	6'b010000;	// Sends a byte over SDA_IN
localparam RECEIVING_BYTE	=	6'b100000;	// Receives a byte over SDA_OUT

always @ (posedge CLK) begin
	if (RESET) begin
		bytes_count	=	0;
		bits_count	=	0;
		ACK	=	0;
		slave_addr	=	0;
		SDA_IN		=	0;
		WR_DATA		=	0;
		sl_state		=	WAITING_START;
	end else begin
		sl_state	<=	next_sl_state;
		previous_SCL	<=	SCL;
	end

end

always @ (*) begin

	case (sl_state)
		WAITING_START: begin
			if ((previous_SDA - SDA_OUT) == 1) begin

#8				next_sl_state	=	RECEIVING_BYTE;
			end else begin
				bytes_count	=	0;
				bits_count	=	0;
				ACK	=	0;
				slave_addr	=	0;
				next_sl_state	=	WAITING_START;
				previous_SDA	=	SDA_OUT;
			end
		end
		VERIFYING_ADDR: begin
			if (I2C_ADDR == slave_addr) begin
				ACK	=	1;	// Flag set for receiving sl_state
				next_sl_state	=	SENDING_ACK;
			end else begin
				next_sl_state = WAITING_START;			
			end
		end
		SENDING_ACK: begin
			SDA_IN 	=	1;
			if (RNW) begin
				next_sl_state	=	RECEIVING_BYTE;
			end else begin
				next_sl_state	=	SENDING_BYTE;
			end
		end
		WAITING_ACK: begin
			SDA_IN	=	0;
			if (SDA_OUT) begin
				if (RNW) begin
					next_sl_state	=	RECEIVING_BYTE;
				end else begin
					next_sl_state	=	SENDING_BYTE;
				end
			end else begin
				next_sl_state	=	WAITING_START;
			end
		end
		SENDING_BYTE: begin
			if (bits_count <= 7) begin
				// The cycle is analogous to the receiving one
				SDA_IN	=	RD_DATA[bits_count+8*bytes_count];
				next_sl_state	=	SENDING_BYTE;
			end else begin
				bytes_count	=	bytes_count + 1;
				next_sl_state	=	WAITING_ACK;
			end
			bits_count	=	bits_count + 1;		
		end
		RECEIVING_BYTE: begin
			SDA_IN	=	0;

			if (posedge_SCL) begin

				if (!ACK) begin
					// First of all the address and rnw is received
					if (bits_count <= 6) begin	// Tis gets bits from 0 to 6
						slave_addr	=	{slave_addr, SDA_OUT};	// Input address bit is concatenated
						next_sl_state	=	RECEIVING_BYTE;
					end else begin
						RNW		=	SDA_OUT;		
						next_sl_state	=	VERIFYING_ADDR;
					end
				end else begin
					if (bits_count <= 7) begin
						WR_DATA[bits_count+8*bytes_count]	=	SDA_OUT;
						next_sl_state	=	RECEIVING_BYTE;
					end else begin
						bytes_count	=	bytes_count + 1;
						next_sl_state	=	SENDING_ACK;
                    end
				end
				bits_count	=	bits_count + 1;		// Keeps the bit counter going
			end
		end
	endcase
end

assign  posedge_SCL     =       SCL && ~previous_SCL;

endmodule
