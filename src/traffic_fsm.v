// TRAFFIC LIGHT FSM  
//============================================================
module traffic_fsm(
    input  wire        clk,
    input  wire        reset_n,

    // Inputs from Person 2 modules
    input  wire        clean_ped_button,   // debounced button
    input  wire        night_mode,         // SW0
    input  wire        green_done,
    input  wire        yellow_done,
    input  wire        red_done,
    input  wire        walk_done,

    // Outputs to LEDs
    output reg         red_led,
    output reg         yellow_led,
    output reg         green_led,
    output reg         walk_led,
    output reg         dont_walk_led,

    output reg         walk_enable,        // start countdown + beep
    output reg         blink_enable,        // night mode blinking
	 output reg 		  ped_request_out
);

//============================================================
// STATE ENCODING
//============================================================
localparam  S_GREEN  = 3'b000,
            S_YELLOW = 3'b001,
            S_RED    = 3'b010,
            S_WALK   = 3'b011,
            S_NIGHT  = 3'b100;

reg [2:0] state, next_state;

// Pedestrian request memory
reg ped_request;

//============================================================
// PEDESTRIAN REQUEST LOGIC
//============================================================
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        ped_request <= 1'b0;
    else begin
        // request is set when button pressed (but not in night mode)
        if (clean_ped_button && !night_mode)
            ped_request <= 1'b1;

        // request is cleared AFTER walk phase finishes
        else if (state == S_WALK)
            ped_request <= 1'b0;
    end
end

//============================================================
// FSM STATE REGISTER
//============================================================
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        state <= S_GREEN;
    else
        state <= next_state;
end

//============================================================
// FSM NEXT STATE LOGIC
//============================================================
always @(*) begin
    next_state = state; // default

    case(state)

        //========================
        // GREEN
        //========================
        S_GREEN: begin
            if (night_mode)
                next_state = S_NIGHT;
            else if (green_done)
                next_state = S_YELLOW;
        end

        //========================
        // YELLOW
        //========================
        S_YELLOW: begin
            if (night_mode)
                next_state = S_NIGHT;
            else if (yellow_done)
                next_state = S_RED;
        end

        //========================
        // RED
        //========================
        S_RED: begin
            if (night_mode)
                next_state = S_NIGHT;
            else if (red_done && ped_request)
                next_state = S_WALK;
            else if (red_done && !ped_request)
                next_state = S_GREEN;
        end

        //========================
        // WALK
        //========================
        S_WALK: begin
            if (night_mode)
                next_state = S_NIGHT;
            else if (walk_done)
                next_state = S_GREEN;
        end

        //========================
        // NIGHT MODE
        //========================
        S_NIGHT: begin
            if (!night_mode)
                next_state = S_GREEN;
        end

        default: next_state = S_GREEN;
    endcase
end

//============================================================
// OUTPUT LOGIC (LEDs, walk_enable, blink_enable)
//============================================================
always @(*) begin
    // default OFF
    red_led        = 0;
    yellow_led     = 0;
    green_led      = 0;
    walk_led       = 0;
    dont_walk_led  = 1;   // by default don't walk
    walk_enable    = 0;
    blink_enable   = 0;
	 ped_request_out = ped_request;

    case(state)

        S_GREEN: begin
            green_led      = 1;
            dont_walk_led  = 1;
        end

        S_YELLOW: begin
            yellow_led     = 1;
            dont_walk_led  = 1;
        end

        S_RED: begin
            red_led        = 1;
            dont_walk_led  = 1;
        end

        S_WALK: begin
            red_led        = 1;
            walk_led       = 1;
            dont_walk_led  = 0;
            walk_enable    = 1;
        end

        S_NIGHT: begin
            blink_enable   = 1;
            // all other lights stay OFF
        end

    endcase
end

endmodule

