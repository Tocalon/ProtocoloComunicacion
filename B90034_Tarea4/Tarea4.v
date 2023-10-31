module Generador(CLK ,RESET, START_STB, RNW, ACK, I2C_ADDR, WR_DATA, SDA_IN, SCL, SDA_OUT, SDA_OE, RD_DATA); 

input CLK, RESET, START_STB, RNW, SDA_IN; 
output SCL, SDA_OUT, ACK, SDA_OE;
input [6:0]I2C_ADDR; 
input [15:0]WR_DATA; 
output [15:0]RD_DATA; 

reg [1:0]count_CLK; 
reg [3:0] counter_bits, prox_counter_bits;
reg[6:0] estado, prox_estado; 
wire write, trans_finalizada, CLK_DIV4, SCL;  
wire [15:0] data_finalizada; 
reg SDA_reg,  SDA_OUT, SDA_OE, SCL_reg, CLK_DIV2, RD_DATA_REG, PROX_SDA_OE;   
reg[7:0] dato_recibido,prox_dato_recibido; 

assign  write=~WR_DATA[13]&& WR_DATA[12]; 
assign data_finalizada=(counter_bits==15);
assign SCL=SCL_reg; 
assign RD_DATA=RD_DATA_REG;
assign trans_finalizada=& counter_bits; 

localparam INICIO=3'b001; 
localparam DATA_STATE_WRITE=3'b010; 
localparam DATA_STATE_READ= 3'b100; 

always @(posedge CLK) begin
    if(RESET) begin
        estado<=INICIO; 
        dato_recibido<=8'h00;
        count_CLK<=2'b00;
        counter_bits<=5'h00; //revisar la logica 
        //SCL<=0; 
        SDA_OUT<=1; 
    end else begin 
        estado<=prox_estado; 
        dato_recibido<=prox_dato_recibido; 
        counter_bits<=prox_counter_bits; 
        count_CLK<=count_CLK+1; 
    end 
end 

always @(*) begin
prox_estado=estado; 
prox_dato_recibido=dato_recibido;
prox_counter_bits=counter_bits;
SDA_OUT=1'b0; 
SDA_OE= 1'b0;
    case(estado)
        INICIO: begin
            if (START_STB && write) prox_estado = DATA_STATE_WRITE; 
            if(START_STB && ~write) prox_estado=DATA_STATE_READ;   
        end
        DATA_STATE_WRITE: begin 
            if (ACK) begin
                prox_estado= INICIO;
            end
            SDA_OE=1'b1 ; 
            //SDA_reg= 8'bB90034; 
        end
        DATA_STATE_READ: begin
            if (ACK) begin 
                prox_estado=INICIO; 
            end 
            SDA_OE=1'b1; 
            SDA_OUT=8'bzzzzzzzz;
        end
        default: 
        begin
            prox_estado=INICIO; 
            prox_dato_recibido=0; 
        end
    endcase
end


always @(posedge CLK)begin 
    if (RESET)begin 
        CLK_DIV2<=0;
        count_CLK<=0;  
    end else begin 
        CLK_DIV2<= ~CLK_DIV2;
        count_CLK<=count_CLK+1; 
    end 
end 

//incremento de counters_bits 
always @(posedge SCL) begin 
    if (RESET||START_STB)begin 
        counter_bits<=0; 
        SDA_OE<=0; 
    end else begin 
        counter_bits<=~counter_bits+1; 
        SDA_OUT<=data_finalizada[15-counter_bits]; 
        SDA_OE<=PROX_SDA_OE; 
    end 
end 

assign CLK_DIV4=count_CLK[1]; 
assign SCL=CLK_DIV4; 

endmodule 