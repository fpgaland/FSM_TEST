
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ONE_YEAR
// Function: State machine. Simply transition January->February->...->December
//           And output the status as binary value (1, 2, ..., 12)
//////////////////////////////////////////////////////////////////////////////////

module ONE_YEAR (
    input  wire                         CLK,
    input  wire                         RST,            /* Active high */
    input  wire                         FSM_RST,        /* Reset input to FSM */
    input  wire                         TRG,            /* Trigger for transitioning state */
    output reg [4:0]                    STATE_OUT       /* State output. MSB = 1 when ilegal state */
);

/********************************************************************************/
/**** State definition **********************************************************/
/********************************************************************************/

parameter JANUARY   = 4'd0;
parameter FEBRUARY  = 4'd1;
parameter MARCH     = 4'd2;
parameter APRIL     = 4'd3;
parameter MAY       = 4'd4;
parameter JUNE      = 4'd5;
parameter JULY      = 4'd6;
parameter AUGUST    = 4'd7;
parameter SEPTEMBER = 4'd8;
parameter OCTOBER   = 4'd9;
parameter NOVEMBER  = 4'd10;
parameter DECEMBER  = 4'd11;


/********************************************************************************/
/**** Signals *******************************************************************/
/********************************************************************************/

/* Trigger edge detect */
reg                                     trg_ff1;
reg                                     trg_ff2;
reg                                     trg_redg;

/* JANUARY to FEBRUARY trigger */
reg                                     j2f_ff1;
reg                                     j2f_ff2;
reg                                     j2f_trg;

/* State macine */
reg [3:0]                               current_state;
reg [3:0]                               next_state;


/********************************************************************************/
/**** Behaviour *****************************************************************/
/********************************************************************************/

/* Trigger edge detect */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        trg_ff1     <=  1'b0;
        trg_ff2     <=  1'b0;
        trg_redg    <=  1'b0;
    end else begin
        trg_ff1     <=  TRG;
        trg_ff2     <=  trg_ff1;
        trg_redg    <=  trg_ff1 & (~trg_ff2);
    end
end


/* JANUARY to FEBRUARY trigger */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        j2f_ff1     <=  1'b0;
        j2f_ff2     <=  1'b0;
        j2f_trg     <=  1'b0;
    end else begin
        j2f_ff1     <=  1'b1;
        j2f_ff2     <=  j2f_ff1;
        j2f_trg     <=  j2f_ff2;
    end
end


/* State machine */
always @ (posedge CLK or posedge FSM_RST) begin
    if (FSM_RST) begin
        current_state   <=  JANUARY;
    end else begin
        current_state   <=  next_state;
    end
end

always @ (current_state or j2f_trg or trg_redg) begin
    case (current_state)
        JANUARY     : begin
                if (j2f_trg == 1'b1)
                    next_state  <=  FEBRUARY;     /* Transition immediately to check if the FSM works */
                else
                    next_state  <=  current_state;
            end

        FEBRUARY    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  MARCH;
                else
                    next_state  <=  current_state;
            end

        MARCH    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  APRIL;
                else
                    next_state  <=  current_state;
            end

        APRIL    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  MAY;
                else
                    next_state  <=  current_state;
            end

        MAY    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  JUNE;
                else
                    next_state  <=  current_state;
            end

        JUNE    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  JULY;
                else
                    next_state  <=  current_state;
            end

        JULY    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  AUGUST;
                else
                    next_state  <=  current_state;
            end

        AUGUST    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  SEPTEMBER;
                else
                    next_state  <=  current_state;
            end

        SEPTEMBER    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  OCTOBER;
                else
                    next_state  <=  current_state;
            end

        OCTOBER    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  NOVEMBER;
                else
                    next_state  <=  current_state;
            end

        NOVEMBER    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  DECEMBER;
                else
                    next_state  <=  current_state;
            end

        DECEMBER    : begin
                if (trg_redg == 1'b1)
                    next_state  <=  JANUARY;
                else
                    next_state  <=  current_state;
            end

        default     : 
            next_state  <=  JANUARY;

    endcase
end


/* State outpu */
always @ (posedge CLK or posedge RST) begin
    if (RST) begin
        STATE_OUT   <=  5'b10000;
    end else begin
        case (current_state)
            JANUARY     : STATE_OUT   <=  5'b00000 + 5'd1;
            FEBRUARY    : STATE_OUT   <=  5'b00000 + 5'd2;
            MARCH       : STATE_OUT   <=  5'b00000 + 5'd3;
            APRIL       : STATE_OUT   <=  5'b00000 + 5'd4;
            MAY         : STATE_OUT   <=  5'b00000 + 5'd5;
            JUNE        : STATE_OUT   <=  5'b00000 + 5'd6;
            JULY        : STATE_OUT   <=  5'b00000 + 5'd7;
            AUGUST      : STATE_OUT   <=  5'b00000 + 5'd8;
            SEPTEMBER   : STATE_OUT   <=  5'b00000 + 5'd9;
            OCTOBER     : STATE_OUT   <=  5'b00000 + 5'd10;
            NOVEMBER    : STATE_OUT   <=  5'b00000 + 5'd11;
            DECEMBER    : STATE_OUT   <=  5'b00000 + 5'd12;
            default     : STATE_OUT   <=  5'b11111;         /* Ilegal state */
        endcase
    end
end


endmodule