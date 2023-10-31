`include "Tester.v"
`include "Receptor.v"
`include "Transmisor.v"
module spi_testbench;
    input wire Transaccion, CKP, CPH, CLK, RESET, SCK, MOSI,  MISO, CS, SS;      

initial begin
    $dumpfile("resultados_Tarea5.vcd");
    $dumpvars(-1, transmitter);
    $dumpvars(-1, probador);
	$dumpvars(-1, receiver1);
    $dumpvars(-1, receiver2);
    $dumpvars(-1, receiver3);
    $dumpvars;
end
wire MISO2SLAVE2;
wire MISO2SLAVE3;
wire CS2SS;

    // Instancia del módulo transmisor
    SPI_Transmitter transmitter (
        .Transaccion(Transaccion),
        .CLK(CLK),
        .RESET(RESET),
        .CKP(CKP),
        .CPH(CPH),
        .CS(CS2SS),
        .SCK(SCK),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    tester probador (
        .Transaccion(Transaccion),
        .CKP(CKP),
        .CPH(CPH),
        .CLK(CLK),
        .RESET(RESET),
        .SCK(SCK)
    );

    SPI_Receiver receiver1 (
        .Transaccion(Transaccion),
        .CKP(CKP),
        .CPH(CPH),
        .MISO(MISO2SLAVE2),  
        .SCK(SCK),
        .MOSI(MOSI),
        .SS(CS2SS)
    );

    SPI_Receiver receiver2 (
        .Transaccion(Transaccion),
        .CKP(CKP),
        .CPH(CPH),
        .MISO(MISO2SLAVE3),  
        .SCK(SCK),
        .MOSI(MISO2SLAVE2),
        .SS(CS2SS)
    );

    SPI_Receiver receiver3 (
        .Transaccion(Transaccion),
        .CKP(CKP),
        .CPH(CPH),
        .MISO(MISO),  
        .SCK(SCK),
        .MOSI(MISO2SLAVE3),
        .SS(CS2SS)
    );

endmodule