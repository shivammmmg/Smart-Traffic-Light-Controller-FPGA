//============================================================
// Walk countdown timer
//  - start: 1-cycle pulse from FSM (when entering WALK)
//  - enable: stays high while in Walk state (walk_enable)
//  - value: current BCD digit (0..9) for HEX0
//  - done : 1-cycle pulse when countdown reaches 0
//============================================================
module walk_countdown_timer #(
    parameter integer START_VALUE    = 4'd5,         // walk length in seconds
    parameter integer TICKS_PER_SEC  = 50_000_000    // 1 second @ 50MHz
)(
    input  wire       clk,
    input  wire       reset_n,       // active-low
    input  wire       start,         // 1-cycle pulse
    input  wire       enable,        // walk_enable (FSM Walk state)
    output reg [3:0]  value,         // BCD digit for HEX0
    output reg        done           // 1-cycle pulse when finished
);

    reg [25:0] tick_cnt;   // enough bits for 50M-1
    reg        active;     // internal: high while counting

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tick_cnt <= 26'd0;
            value    <= START_VALUE;
            active   <= 1'b0;
            done     <= 1'b0;
        end else begin
            done <= 1'b0;  // default

            // start new countdown
            if (start) begin
                value    <= START_VALUE;
                tick_cnt <= 26'd0;
                active   <= 1'b1;
            end else if (active && enable) begin
                // count "seconds"
                if (tick_cnt == TICKS_PER_SEC - 1) begin
                    tick_cnt <= 26'd0;
                    if (value != 4'd0) begin
                        value <= value - 4'd1;
                    end else begin
                        active <= 1'b0;   // stop counting
                        done   <= 1'b1;   // pulse when reaching 0
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1'b1;
                end
            end else begin
                tick_cnt <= 26'd0;
            end
        end
    end

endmodule


