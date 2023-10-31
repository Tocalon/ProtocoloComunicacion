module Receptor(CLK ,RESET, START_STB, RNW,I2C_ADDR,ACK,  WR_DATA, SDA_IN, SCL, SDA_OUT, SDA_OE, RD_DATA);

input CLK, RESET,  START_STB,RNW,SDA_OUT; 
output SCL, SDA_OE, SDA_IN,  ACK, data_out; 
input [6:0]I2C_ADDR; 
input [15:0]WR_DATA; 
output [15:0]RD_DATA;

 
reg [1:0]count_CLK; 
reg [3:0] counter_bits, prox_counter_bits;
reg[2:0] estado, prox_estado; 
wire write, data_finalizada, CLK_DIV4; 
reg SCL_reg, ACK, SDA_reg, SDA_OE, data_out, CLK_DIV2;   
reg[7:0] dato_recibido,prox_dato_recibido; 

assign  write=~WR_DATA[13]&& WR_DATA[14]; 
assign data_finalizada=(counter_bits==15);
assign SCL = SCL_reg; 
assign SDA_OUT = SDA_reg;

localparam INICIO=3'b001; 
localparam DATA_STATE_RECEIVED=3'b010; 

always @(posedge CLK) begin
    if(RESET) begin
        estado<=INICIO; 
        dato_recibido<=8'h00;
        count_CLK<=2'b00;
        counter_bits<=5'h00; //revisar la logica 
        SCL_reg<=0; 
        SDA_reg<=1; 
    end else begin 
        estado<=prox_estado; 
        dato_recibido<=prox_dato_recibido; 
        counter_bits<=prox_counter_bits; 
        count_CLK<=count_CLK+1; 
    end 
end  

always @(*)begin
prox_estado=estado; 
prox_dato_recibido=dato_recibido;
prox_counter_bits=counter_bits;
ACK = 1'b0;
data_out= 8'bzzzzzzzz;
SDA_reg=1'b0; 
SDA_OE= 1'b0;
    case(estado)
    INICIO: 
        if (SDA_IN == 1'b0) begin
        prox_estado =DATA_STATE_RECEIVED;
        dato_recibido <= 8'b00000000;
        ACK = 1'b1;  
    end
    DATA_STATE_RECEIVED:
    if  (SCL) begin
        dato_recibido <= {dato_recibido[6:0], SDA_IN};
        ACK = 1'b1; 
        dato_recibido <= dato_recibido+1;
        // Enviar ACK para indicar que hemos recibido un byte.
      end else if (dato_recibido==7) begin
        // Procesar los datos recibidos (puedes agregar tu lógica específica aquí).
        prox_estado = INICIO;
        ACK = 1'b0; // Enviar NACK para indicar el final de la transmisión.
        data_out = dato_recibido;; // Datos recibidos.
      end
    default: 
        begin
            prox_estado=INICIO; 
            prox_dato_recibido=0; 
        end
    endcase
end 


endmodule 