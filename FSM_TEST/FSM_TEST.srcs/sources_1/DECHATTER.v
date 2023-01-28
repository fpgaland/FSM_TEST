
//////////////////////////////////////////////////////////////////////////////////
// Module Name: DECATTER
// Function: Remove chattering of mechanical switches
//////////////////////////////////////////////////////////////////////////////////

module DECATTER #(
    parameter                           P_1MS_CNT  = 100000,    /* = (1 ms) / (T of CLK [ms]) */
    parameter                           P_N_10MS   = 10         /* Switch output when input is stable for P_N_10MS [x10ms] */
) (
    input  wire                         CLK,
    input  wire                         RST,                    /* Active high */
    input  wire                         DIN,
    output reg                          DOUT                    /* Result valid. 1 clock pulse */
);

/********************************************************************************/
/**** Functions *****************************************************************/
/********************************************************************************/
function integer min_bw (input integer n);    /* Minimum required bit width for n */
    integer cnt;
    integer n_shift;
begin    
    cnt = 0;
    n_shift = n;

    while (n_shift > 0) begin
        n_shift = n_shift >> 1;
        cnt = cnt + 1;
    end
    
    min_bw = cnt;
end
endfunction

/********************************************************************************/
/**** Local parameters **********************************************************/
/********************************************************************************/

localparam                  P_BW_CNT = min_bw(P_1MS_CNT - 1);   /* Bit width of 1ms counter */
localparam [P_BW_CNT - 1:0] P_CNT_MAX = P_1MS_CNT - 1;          /* 1ms counte max value */


/********************************************************************************/
/**** Signals *******************************************************************/
/********************************************************************************/

/* Make 1ms & 10ms */
reg [P_BW_CNT - 1:0]                    cnt_1ms;                /* 1ms counter */
reg [3:0]                               cnt_10ms;               /* 10ms counter */
reg                                     tim_10ms;               /* 10ms timing pulse */

/* Input synchronizer */
reg                                     din_ff1;
reg                                     din_ff2;

/* Latch input onece in 10 ms */
reg [P_N_10MS - 1:0]                    din_lat;


/********************************************************************************/
/**** Behaviour *****************************************************************/
/********************************************************************************/

/* Make 1ms & 10ms */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        cnt_1ms <=  {P_BW_CNT{1'b0}};
    end else begin
        if (cnt_1ms == P_CNT_MAX)
            cnt_1ms <=  {P_BW_CNT{1'b0}};
        else
            cnt_1ms <=  cnt_1ms + 1'b1;
    end
end

always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        cnt_10ms <=  4'd0;
    end else begin
        if (cnt_1ms == P_CNT_MAX)
            if (cnt_10ms == 4'd9)
                cnt_10ms <=  4'd0;
            else
                cnt_10ms <=  cnt_10ms + 1'b1;
        else
            cnt_10ms <=  cnt_10ms;
    end
end

always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        tim_10ms <=  1'b0;
    end else begin
        if ((cnt_1ms == P_CNT_MAX) && (cnt_10ms == 4'd9))
            tim_10ms <=  1'b1;                              /* 1-clk pulse in 10 ms */
        else
            tim_10ms <=  1'b0;
    end
end


/* Input synchronizer */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        din_ff1 <=  1'b0;
        din_ff2 <=  1'b0;
    end else begin
        din_ff1 <=  DIN;
        din_ff2 <=  din_ff1;
    end
end


/* Latch input onece in 10 ms */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        din_lat <=  {P_N_10MS{1'b0}};
    end else begin
        if (tim_10ms == 1'b1)
            din_lat <=  {din_lat[P_N_10MS - 2:0], din_ff2};
        else
            din_lat <=  din_lat;
    end
end


/* Output */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        DOUT <=  1'b0;
    end else begin
        if (din_lat == {P_N_10MS{1'b0}})
            DOUT <=  1'b0;
        else
            if (din_lat == {P_N_10MS{1'b1}})
                DOUT <=  1'b1;
            else
                DOUT <=  DOUT;
    end
end


endmodule