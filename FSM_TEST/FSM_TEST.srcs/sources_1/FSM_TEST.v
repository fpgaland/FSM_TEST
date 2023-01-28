
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FSM_TEST
// Function: State machine test
//////////////////////////////////////////////////////////////////////////////////

module FSM_TEST (
    input  wire                         CLK,
    input  wire                         RST,                    /* Active high */
    input  wire                         RST_BTN,                /* FSM reset button */
    input  wire                         TRG,                    /* State transition trigger */
    output wire                         LED0_R,
    output wire                         LED0_G,
    output wire                         LED0_B,
    output wire                         LED1_R,
    output wire                         LED1_G,
    output wire                         LED1_B,
    output wire                         LED2,
    output wire                         LED3,
    output wire                         LED4,
    output wire                         LED5,
    input  wire [17:0]                  RXD,
    output wire [17:0]                  TXD
);


/********************************************************************************/
/**** Signals *******************************************************************/
/********************************************************************************/

/* Clock */
wire                                    clk_100m;
wire                                    clk_153m;
wire                                    clk_11m;

wire                                    locked_100;
wire                                    locked_11;
wire                                    locked_153;

/* Reset */
reg                                     rst_pre_n;
reg                                     rst_pre_ff1_n;
reg                                     rst_pre_ff2_n;
reg                                     rst_pre_ff3_n;
reg                                     rst_pre_ff4_n;

reg                                     rst_100_ff1_n;
reg                                     rst_100_ff2_n;
reg                                     rst_100_ff3_n;
reg                                     rst_100_ff4_n;
reg                                     rst_100_n;

reg                                     rst_11_ff1;
reg                                     rst_11_ff2;
reg                                     rst_11_ff3;
reg                                     rst_11_ff4;
reg                                     rst_11;

reg                                     rst_153_ff1;
reg                                     rst_153_ff2;
reg                                     rst_153_ff3;
reg                                     rst_153_ff4;
reg                                     rst_153;

/* Remove chattering of TRG button */
wire                                    trg_11;
wire                                    trg_153;

/* State machine */
wire [4:0]                              state_out_11;
wire [4:0]                              state_out_153;


/********************************************************************************/
/**** Behaviour *****************************************************************/
/********************************************************************************/

/* Clock */
clk_wiz_100 clk_wiz_100 (
    // Clock out ports
    .clk_100m_out   (clk_100m),         // output clk_100m_out
    // Status and control signals
    .reset          (RST),              // input reset
    .locked         (locked_100),       // output locked
   // Clock in ports
    .clk_100m_in    (CLK));             // input clk_100m_in

clk_wiz_11 clk_wiz_11 (
    // Clock out ports
    .clk_11m_out   (clk_11m),           // output clk_100m_out
    // Status and control signals
    .reset          (RST),              // input reset
    .locked         (locked_11),        // output locked
   // Clock in ports
    .clk_100m_in    (clk_100m));        // input clk_100m_in

clk_wiz_153 clk_wiz_153 (
    // Clock out ports
    .clk_153m_out   (clk_153m),         // output clk_100m_out
    // Status and control signals
    .reset          (RST),              // input reset
    .locked         (locked_153),       // output locked
   // Clock in ports
    .clk_100m_in    (clk_100m));        // input clk_100m_in


/* Reset */
always @ (posedge CLK) begin
    rst_pre_n       <=  locked_100 & locked_11 & locked_153;
    rst_pre_ff1_n   <=  rst_pre_n;
    rst_pre_ff2_n   <=  rst_pre_ff1_n;
    rst_pre_ff3_n   <=  rst_pre_ff2_n;
    rst_pre_ff4_n   <=  rst_pre_ff3_n;
end

always @ (posedge CLK or negedge rst_pre_ff4_n) begin
    if (rst_pre_ff4_n == 1'b0) begin
        rst_100_ff1_n   <=  1'b0;
        rst_100_ff2_n   <=  1'b0;
        rst_100_ff3_n   <=  1'b0;
        rst_100_ff4_n   <=  1'b0;
        rst_100_n       <=  1'b0;
    end else begin
        rst_100_ff1_n   <=  1'b1;
        rst_100_ff2_n   <=  rst_100_ff1_n;
        rst_100_ff3_n   <=  rst_100_ff2_n;
        rst_100_ff4_n   <=  rst_100_ff3_n;
        rst_100_n       <=  rst_100_ff4_n;
    end
end

always @ (posedge CLK or negedge rst_pre_ff4_n) begin
    if (rst_pre_ff4_n == 1'b0) begin
        rst_11_ff1   <=  1'b1;
        rst_11_ff2   <=  1'b1;
        rst_11_ff3   <=  1'b1;
        rst_11_ff4   <=  1'b1;
        rst_11       <=  1'b1;
    end else begin
        rst_11_ff1   <=  1'b0;
        rst_11_ff2   <=  rst_11_ff1;
        rst_11_ff3   <=  rst_11_ff2;
        rst_11_ff4   <=  rst_11_ff3;
        rst_11       <=  rst_11_ff4;
    end
end

always @ (posedge CLK or negedge rst_pre_ff4_n) begin
    if (rst_pre_ff4_n == 1'b0) begin
        rst_153_ff1   <=  1'b1;
        rst_153_ff2   <=  1'b1;
        rst_153_ff3   <=  1'b1;
        rst_153_ff4   <=  1'b1;
        rst_153       <=  1'b1;
    end else begin
        rst_153_ff1   <=  1'b0;
        rst_153_ff2   <=  rst_153_ff1;
        rst_153_ff3   <=  rst_153_ff2;
        rst_153_ff4   <=  rst_153_ff3;
        rst_153       <=  rst_153_ff4;
    end
end


/* Remove chattering of TRG button */
DECATTER #(
    .P_1MS_CNT  (   11000       ),  //  = 100000,    /* = (1 ms) / (T of CLK [ms]) */
    .P_N_10MS   (   10          )   //  = 10         /* Switch output when input is stable for P_N_10MS [x10ms] */
) DECATTER_11 (
    .CLK        (   clk_11m     ),
    .RST        (   rst_11      ),                   /* Active high */
    .DIN        (   TRG         ),
    .DOUT       (   trg_11      )                    /* Result valid. 1 clock pulse */
);

DECATTER #(
    .P_1MS_CNT  (   153000      ),  //  = 100000,    /* = (1 ms) / (T of CLK [ms]) */
    .P_N_10MS   (   10          )   //  = 10         /* Switch output when input is stable for P_N_10MS [x10ms] */
) DECATTER_153 (
    .CLK        (   clk_153m    ),
    .RST        (   rst_153     ),                   /* Active high */
    .DIN        (   TRG         ),
    .DOUT       (   trg_153     )                    /* Result valid. 1 clock pulse */
);


/* State machine */
ONE_YEAR ONE_YEAR_11 (
    .CLK        (   clk_11m     ),
    .RST        (   rst_11      ),                   /* Active high */
    .FSM_RST    (   RST_BTN     ),                   /* Reset input to FSM */
    .TRG        (   trg_11      ),                   /* Trigger for transitioning state */
    .STATE_OUT  (   state_out_11    )                /* State output. MSB = 1 when ilegal state */
);

ONE_YEAR ONE_YEAR_153 (
    .CLK        (   clk_153m    ),
    .RST        (   rst_153     ),                   /* Active high */
    .FSM_RST    (   RST_BTN     ),                   /* Reset input to FSM */
    .TRG        (   trg_153     ),                   /* Trigger for transitioning state */
    .STATE_OUT  (   state_out_153   )                /* State output. MSB = 1 when ilegal state */
);


/* LED control */
LED_12_AND_W #(
    .P_PWM_PERIOD  (   110      )   //  0.01ms
) LED_12_AND_W_11 (
    .CLK        (   clk_11m     ),
    .RST        (   rst_11      ),                   /* Active high */
    .COLOR_SEL  (   state_out_11[3:0]   ),           /* 0=Write, 1=Red, 2=Orange, ..., 5=Green, ..., 9=Blue, ...*/
    .LED_PWM_R  (   LED0_R      ),
    .LED_PWM_G  (   LED0_G      ),
    .LED_PWM_B  (   LED0_B      )
);

LED_12_AND_W #(
    .P_PWM_PERIOD  (   1530    )   //  0.01ms
) LED_12_AND_W_153 (
    .CLK        (   clk_153m    ),
    .RST        (   rst_153     ),                   /* Active high */
    .COLOR_SEL  (   state_out_153[3:0]  ),           /* 0=Write, 1=Red, 2=Orange, ..., 5=Green, ..., 9=Blue, ...*/
    .LED_PWM_R  (   LED1_R      ),
    .LED_PWM_G  (   LED1_G      ),
    .LED_PWM_B  (   LED1_B      )
);

assign  LED2    =  state_out_11[4];
assign  LED3    =  state_out_153[4];
assign  LED4    =  RST_BTN;
assign  LED5    =  trg_11;


/* CPUs for consuming FPGA resource */
genvar i;
generate
    for (i = 0; i < 18; i = i + 1) begin
        cpu_uart_wrapper CPU (
            .CLK    (   clk_100m    ),
            .RST_N  (   rst_100_n   ),
            .RXD    (   RXD[i]      ),
            .TXD    (   TXD[i]      )
        );
    end
endgenerate


endmodule