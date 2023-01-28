`timescale 1ns / 1ps

module TB_FSM_TEST();

/* Parameters */
parameter MAINCLK_PERIOD = 10;
parameter TIME_1US       = 1000;
parameter TIME_1MS       = 1000000;


/* Signals */
bit             clk;
bit             rst;
bit             rst_btn;
bit             trg;
bit   [17:0]    rxd;
bit             start_trg;


/* DUT */
FSM_TEST FSM_TEST (
    .CLK        (   clk         ),
    .RST        (   rst         ),                /* Active high */
    .RST_BTN    (   rst_btn     ),                /* FSM reset button */
    .TRG        (   trg         ),                /* State transition trigger */
    .LED0_R     (               ),
    .LED0_G     (               ),
    .LED0_B     (               ),
    .LED1_R     (               ),
    .LED1_G     (               ),
    .LED1_B     (               ),
    .LED2       (               ),
    .LED3       (               ),
    .LED4       (               ),
    .LED5       (               ),
    .RXD        (   rxd         ),
    .TXD        (               )
);


/* Clock generation */
initial forever #(MAINCLK_PERIOD) clk = ~clk;


/* Trigger */
//initial forever begin
//    if (start_trg == 1'b1) begin
//        #(1);
//        trg = 1'b1;
//        #(TIME_1MS * 100);
//        trg = 1'b0;
//        #(TIME_1MS * 100);
//    end
//end


/* Main */
initial begin
    rst     = 1'b1;
    rst_btn = 1'b0;
    trg     = 1'b0;
    rxd     = 18'h3FFFF;
    start_trg = 1'b0;

    #(TIME_1US);

     rst     = 1'b0;

    #(TIME_1US * 500);

    repeat(100) begin
        trg = 1'b1;
        #(TIME_1MS * 100);
        trg = 1'b0;
        #(TIME_1MS * 100);
    end

end



endmodule