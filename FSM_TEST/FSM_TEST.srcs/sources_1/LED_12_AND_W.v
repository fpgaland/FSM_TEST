
//////////////////////////////////////////////////////////////////////////////////
// Module Name: LED_12_AND_W
// Function: Control full color LED to make 12 colors + white
//////////////////////////////////////////////////////////////////////////////////

module LED_12_AND_W #(
    parameter                           P_PWM_PERIOD  = 100000   /* Pwm period */
) (
    input  wire                         CLK,
    input  wire                         RST,                    /* Active high */
    input  wire [3:0]                   COLOR_SEL,              /* 0=Write, 1=Red, 2=Orange, ..., 5=Green, ..., 9=Blue, ...*/
    output reg                          LED_PWM_R,
    output reg                          LED_PWM_G,
    output reg                          LED_PWM_B
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

localparam                  P_BW_CNT = min_bw(P_PWM_PERIOD - 1);   /* Bit width of 1ms counter */
localparam [P_BW_CNT - 1:0] P_CNT_MAX = P_PWM_PERIOD - 1;          /* 1ms counte max value */


/********************************************************************************/
/**** Signals *******************************************************************/
/********************************************************************************/

/* Make 1ms */
reg [P_BW_CNT - 1:0]                    cnt_1ms;                /* 1ms counter */

/* 256 counter */
reg [7:0]                               cnt_256;

/* Duty cycle */
reg [7:0]                               duty_r;
reg [7:0]                               duty_g;
reg [7:0]                               duty_b;


/********************************************************************************/
/**** Behaviour *****************************************************************/
/********************************************************************************/

/* Make 1ms */
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


/* 256 counter */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        cnt_256 <=  8'd0;
    end else begin
        if (cnt_1ms == P_CNT_MAX)
            cnt_256 <=  cnt_256 + 1'b1;
        else
            cnt_256 <=  cnt_256;
    end
end


/* Duty cycle */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        duty_r   <=  8'h00;
        duty_g   <=  8'h00;
        duty_b   <=  8'h00;
    end else begin
        case (COLOR_SEL)
            4'd0  : begin   /* Write */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'hFF;
                end

            4'd1  : begin   /* Deep pink */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'h7F;
                end

            4'd2  : begin   /* Red */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'h00;
                end

            4'd3  : begin   /* Orange */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'h7F;
                    duty_b   <=  8'h00;
                end

            4'd4  : begin   /* Yellow */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'h00;
                end

            4'd5  : begin   /* Yellow green */
                    duty_r   <=  8'h80;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'h00;
                end

            4'd6  : begin   /* Green */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'h00;
                end

            4'd7  : begin   /* Spring green */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'h7F;
                end

            4'd8  : begin   /* Aqua */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'hFF;
                    duty_b   <=  8'hFF;
                end

            4'd9  : begin   /* Deepsky */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'h7F;
                    duty_b   <=  8'hFF;
                end

            4'd10  : begin   /* Blue */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'hFF;
                end

            4'd11  : begin   /* Violet */
                    duty_r   <=  8'h7F;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'hFF;
                end

            4'd12  : begin   /* Magenta */
                    duty_r   <=  8'hFF;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'hFF;
                end

            default  : begin    /* Black */
                    duty_r   <=  8'h00;
                    duty_g   <=  8'h00;
                    duty_b   <=  8'h00;
                end
        endcase
    end
end


/* PWM output */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        LED_PWM_R <=  1'b0;
    end else begin
        if (duty_r == 8'h00)
            LED_PWM_R <=  1'b0;
        else
            if (duty_r == 8'hFF)
                LED_PWM_R <=  1'b1;
            else
                if (cnt_256 <= duty_r)
                    LED_PWM_R <=  1'b1;
                else
                    LED_PWM_R <=  1'b0;
    end
end

always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        LED_PWM_G <=  1'b0;
    end else begin
        if (duty_g == 8'h00)
            LED_PWM_G <=  1'b0;
        else
            if (duty_g == 8'hFF)
                LED_PWM_G <=  1'b1;
            else
                if (cnt_256 <= duty_g)
                    LED_PWM_G <=  1'b1;
                else
                    LED_PWM_G <=  1'b0;
    end
end

always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        LED_PWM_B <=  1'b0;
    end else begin
        if (duty_b == 8'h00)
            LED_PWM_B <=  1'b0;
        else
            if (duty_b == 8'hFF)
                LED_PWM_B <=  1'b1;
            else
                if (cnt_256 <= duty_b)
                    LED_PWM_B <=  1'b1;
                else
                    LED_PWM_B <=  1'b0;
    end
end

endmodule