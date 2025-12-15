// TOP-LEVEL MODULE FOR PROJECT (Person 1 + Person 2)
module traffic_top(
    input  wire        MAX10_CLK1_50, // 50MHz clock from DE10-Lite
    input  wire [1:0]  KEY,           // KEY[0]=reset_n, KEY[1]=ped button (active-low)
    input  wire [9:0]  SW,            // SW[0] = night_mode
    output wire [9:0]  LEDR,          // LEDs for lights + debug
    output wire [6:0]  HEX0          // seven-seg for walk countdown
);

    //========================================================
    // BASIC SIGNALS
    //========================================================
    wire clk        = MAX10_CLK1_50;
    wire reset_n    = KEY[0];      // active-low reset
    wire ped_btn_n  = KEY[1];      // raw pedestrian button (active-low)
    wire night_mode = SW[0];       // SW0 selects night mode

    //========================================================
    // Debounced button (Person 2)
    //========================================================
    wire clean_ped_button;

    debounce_button db_inst (
        .clk         (clk),
        .reset_n     (reset_n),
        .noisy_btn_n (ped_btn_n),
        .clean_pulse (clean_ped_button)
    );

    //========================================================
    // Wires between FSM and timers / blink
    //========================================================
    wire red_led_raw;
    wire yellow_led_raw;
    wire green_led_raw;
    wire walk_led;
    wire dont_walk_led;
	 
	 wire ped_request_indicator;

    wire walk_enable;
    wire blink_enable;

    wire green_done;
    wire yellow_done;
    wire red_done;
    wire walk_done;

    wire blink_signal;

    wire [3:0] walk_digit;
    wire [6:0] hex0_seg;

    //========================================================
    // FSM (Person 1 code)
    //========================================================
    traffic_fsm fsm_inst (
        .clk             (clk),
        .reset_n         (reset_n),

        .clean_ped_button(clean_ped_button),
        .night_mode      (night_mode),
        .green_done      (green_done),
        .yellow_done     (yellow_done),
        .red_done        (red_done),
        .walk_done       (walk_done),

        .red_led         (red_led_raw),
        .yellow_led      (yellow_led_raw),
        .green_led       (green_led_raw),
        .walk_led        (walk_led),
        .dont_walk_led   (dont_walk_led),

        .walk_enable     (walk_enable),
        .blink_enable    (blink_enable),
		  .ped_request_out (ped_request_indicator)
    );

    //========================================================
    // Timers for GREEN / YELLOW / RED
    //========================================================
    localparam integer TICKS_1S = 50_000_000; // 1 second @ 50MHz
	 
	 //========================================================
	// Mode Selection
	// SW1 = Low Traffic
	// SW2 = High Traffic
	// Normal mode = both OFF
	//========================================================
	wire low_mode  = SW[1];
	wire high_mode = SW[2];

	// Green time
	wire [31:0] green_ticks  = high_mode ? (10 * TICKS_1S) :
										low_mode  ? (5  * TICKS_1S) :
														(7  * TICKS_1S);

	// Yellow time
	wire [31:0] yellow_ticks = high_mode ? (3 * TICKS_1S) :
										low_mode  ? (2 * TICKS_1S) :
														(3 * TICKS_1S);

	// Red time
	wire [31:0] red_ticks    = high_mode ? (7 * TICKS_1S) :
										low_mode  ? (4 * TICKS_1S) :
														(5 * TICKS_1S);



phase_timer green_timer (
    .clk          (clk),
    .reset_n      (reset_n),
    .state_active (green_led_raw),
    .duration_ticks(green_ticks),
    .done         (green_done)
);

phase_timer yellow_timer (
    .clk          (clk),
    .reset_n      (reset_n),
    .state_active (yellow_led_raw),
    .duration_ticks(yellow_ticks),
    .done         (yellow_done)
);


phase_timer red_timer (
    .clk          (clk),
    .reset_n      (reset_n),
    .state_active (red_led_raw),
    .duration_ticks(red_ticks),
    .done         (red_done)
);



    //========================================================
    // Walk countdown timer → HEX0 + walk_done
    //========================================================
    // start pulse when walk_enable goes from 0->1
    reg walk_enable_d;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            walk_enable_d <= 1'b0;
        else
            walk_enable_d <= walk_enable;
    end

    wire walk_start_pulse = walk_enable & ~walk_enable_d;

    walk_countdown_timer #(
        .START_VALUE   (4'd7),
        .TICKS_PER_SEC (TICKS_1S)
    ) walk_timer_inst (
        .clk     (clk),
        .reset_n (reset_n),
        .start   (walk_start_pulse),
        .enable  (walk_enable),
        .value   (walk_digit),
        .done    (walk_done)
    );

    // seven-segment decoder from lab
    sevenseg_decoder hex0_dec (
        .bin (walk_digit),
        .seg (hex0_seg)
    );

    assign HEX0 = hex0_seg;
	 

    //========================================================
    // Blink generator for night mode (Person 2)
    //========================================================
    blink_generator #(
        .HALF_PERIOD_TICKS(25_000_000) // 0.5s high, 0.5s low → 1Hz blink
    ) blink_inst (
        .clk       (clk),
        .reset_n   (reset_n),
        .enable    (blink_enable),
        .blink_out (blink_signal)
    );

    //========================================================
    // Map lights + blink to actual LEDs
    //========================================================
    wire yellow_for_led = blink_enable ? blink_signal : yellow_led_raw;

    assign LEDR[0] = green_led_raw;
    assign LEDR[1] = yellow_for_led;
    assign LEDR[2] = red_led_raw;
    assign LEDR[3] = walk_led;
    assign LEDR[4] = dont_walk_led;
	 assign LEDR[5] = ped_request_indicator;
	 
	 assign LEDR[6] = SW[1]; //debug
	 assign LEDR[7] = SW[2]; //debug
	 
    assign LEDR[9:8] = 2'b00;   // unused LEDs off

endmodule