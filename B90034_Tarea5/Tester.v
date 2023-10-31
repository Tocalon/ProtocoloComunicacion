module tester(Transaccion,, CLK, RESET, CKP, CPH, SCK);
    output reg Transaccion, CLK, RESET, CKP, CPH;
    input wire SCK; 

initial begin
    CLK = 0;
    RESET = 1;
    CKP = 0;
    CPH = 0;
    Transaccion = 0;
    #20;

    RESET = 0;
    #28;

    CKP =0;
    CPH = 1;
    #20;
    Transaccion =1;
    #138;
    Transaccion =0;
    #50;

    CKP = 1;
    CPH = 0;
    #50;
    Transaccion =1;
    #138;
    Transaccion = 0;
    #50;

    CKP = 0;
    CPH = 0;
    #50;
    Transaccion =1;
    #138;
    Transaccion = 0;
    #50;

    CKP = 1;
    CPH = 1;
    #50;
    Transaccion =1;
    #138;
    Transaccion = 0;
    #50;

    CKP = 0;
    #30;
    CKP = 1;
    #30
    CKP = 0;
    #30;
    CKP =1;
    #50 $finish;
    
end
always begin
    #5 CLK = ~CLK;
end
endmodule