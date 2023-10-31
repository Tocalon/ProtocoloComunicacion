module SPI_Receiver( Transaccion, CPH, CKP, MISO,  MOSI, SCK, SS); 
    input wire  Transaccion, CKP,  CPH, SCK, MOSI, SS;
    output reg  MISO;


// Variables internas
reg [1:0] ESTADO, PROX_ESTADO;
reg [15:0] Data_register, Prox_Data_register;
reg [7:0] Data1 = 8'b00001001;
reg [7:0] Data2 = 8'b00000100;
reg data_begin_data_register = 0;
reg [4:0] Counter_bits;
wire Choose_SCK, Finish_protcol;
wire [1:0] MODO;
assign Finish_protcol = Counter_bits == 5'b10001;
assign MODO = {CKP, CPH};
assign Choose_SCK = (MODO == 0 || MODO == 3) ? SCK : ~SCK;

parameter IDLE = 2'b00;
parameter Begin_Trans = 2'b01;

always @(posedge Choose_SCK) begin
    if (Transaccion == 0) begin
        ESTADO <= 0;
        Counter_bits <= 0;
        MISO <= 0;
        if (data_begin_data_register ==0) begin
            Data_register <= {Data1, Data2};
            data_begin_data_register <= 1;
        end
    end else begin
        ESTADO <= PROX_ESTADO;
        Counter_bits <= Counter_bits +1;
        Data_register <= Prox_Data_register;

    end
end

always @(*) begin
    Prox_Data_register = Data_register;
    PROX_ESTADO = ESTADO;

    case (ESTADO)
        IDLE: begin
            Counter_bits =0;
            if (Transaccion) begin
                PROX_ESTADO = Begin_Trans;
            end else begin
                PROX_ESTADO = IDLE;
            end
        end 
        Begin_Trans: begin
            if (Counter_bits == 0) begin
                MISO = Data_register[15];
            end else begin
                MISO = Data_register[15];
                Prox_Data_register = {Data_register, MOSI};
            end
            if (Finish_protcol) begin
                PROX_ESTADO = IDLE;
            end
            if (SS == 1) begin
                Counter_bits = 0;
            end
        end
    endcase
end

endmodule