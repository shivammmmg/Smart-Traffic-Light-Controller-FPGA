// Generic phase timer
//  - state_active: 1 when that state/light is ON
//  - done: 1-cycle pulse after DURATION_TICKS
//============================================================
module phase_timer (
    input  wire clk,
    input  wire reset_n,      // active-low
    input  wire state_active, // e.g., green_led_raw
	 input wire [31:0] duration_ticks,
    output reg  done
);

    reg [31:0] cnt;
    reg        prev_active;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cnt         <= 32'd0;
            done        <= 1'b0;
            prev_active <= 1'b0;
        end else begin
            done <= 1'b0;  // default low each cycle

            // detect entering the state
            if (state_active && !prev_active) begin
                cnt <= 32'd0;
            end else if (state_active) begin
                // still in this state → count
                if (cnt == duration_ticks - 1) begin
                    done <= 1'b1;     // ONE-CLOCK PULSE
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end else begin
    // DO NOT reset counter on brief glitches in state_active
    cnt <= cnt;   // hold value instead of resetting
end

            prev_active <= state_active;
        end
    end

endmodule