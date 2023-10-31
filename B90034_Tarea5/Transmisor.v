module SPI_Transmitter(CLK, RESET,  Transaccion, CPH, CKP, MISO, MOSI,  SCK, CS); 

input  wire Transaccion,  CKP, CPH, CLK, RESET, MISO; 
output reg  MOSI, SCK, CS; 

//Variables interna 
reg [1:0] Count_clock, ESTADO, Prox_ESTADO;
reg [15:0] Data_register, Prox_Data_register;
reg [7:0] Data1 = 8'b00000000, Data1_newdata;
reg [7:0] Data2 = 8'b00000001, Data2_newdata;
reg [4:0] Counter_bits ;
wire end_Protocol, Choose_SCK;
assign end_Protocol = Counter_bits == 5'b10001;
wire [1:0] MODO;
assign MODO = {CKP, CPH};
assign Choose_SCK = (MODO == 0 || MODO == 3) ? SCK : ~SCK;

reg CLK_div2;

parameter IDLE = 2'b00;
parameter Begin_Trans = 2'b01;

//DESCRIPCION DE FLIPFLOPS
always @(posedge CLK) begin
    if (RESET == 1) begin
        ESTADO <= IDLE;
        CLK_div2 <= 0;
        Count_clock <= 0;
        Data_register <= {Data1, Data2};
        MOSI <= 0;
        Counter_bits <= 0;
    end else begin
        ESTADO <= Prox_ESTADO;
        CLK_div2 <= ~CLK_div2;
        Count_clock <= Count_clock +1;
    end
    
end

always @(posedge Choose_SCK ) begin
    if (Transaccion == 0) begin
        Counter_bits <= 0;
    end else begin
        Counter_bits <= Counter_bits +1;
        Data_register <= Prox_Data_register;
    end
end

always @(*) begin
    Prox_Data_register = Data_register;
    Prox_ESTADO = ESTADO;

    case (ESTADO)
        IDLE: begin
            Data1_newdata = Data_register[15:8];
            Data2_newdata = Data_register[7:0];
            Counter_bits = 0;
            CS = 1;
            if (CKP) begin
                SCK = 1;
            end else begin
                SCK = 0;
            end
            if (Transaccion && end_Protocol == 0) begin
                Prox_ESTADO = Begin_Trans;
            end else begin
                Prox_ESTADO = IDLE;
            end
        end
        Begin_Trans: begin
            CS = 0;
            SCK = Count_clock[1];
            if (Counter_bits == 0) begin
                MOSI = Data_register[15];
            end else begin
                MOSI = Data_register[15];
                Prox_Data_register = {Data_register, MISO};
            end
            if (end_Protocol) begin
                Prox_ESTADO = IDLE;
            end
        end

    endcase
    
end
endmodule