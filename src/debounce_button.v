//============================================================
// Debounce + 1-cycle pulse for active-low push button
//============================================================
module debounce_button #(
    parameter integer CNT_MAX = 1_000_000   // ~20ms at 50 MHz
)(
    input  wire clk,
    input  wire reset_n,      // active-low reset
    input  wire noisy_btn_n,  // raw KEY input (0 when pressed)
    output reg  clean_pulse   // 1 clock cycle when a new press occurs
);

    // 2-stage synchronizer
    reg sync0, sync1;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync0 <= 1'b1;
            sync1 <= 1'b1;
        end else begin
            sync0 <= noisy_btn_n;
            sync1 <= sync0;
        end
    end

    // Convert to active-high "pressed" level
    wire btn_level = ~sync1;  // 1 when pressed

    // Debounce state
    reg [19:0] cnt;
    reg stable_level;      // debounced level
    reg prev_stable_level; // for edge detect

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cnt              <= 20'd0;
            stable_level     <= 1'b0;
            prev_stable_level<= 1'b0;
            clean_pulse      <= 1'b0;
        end else begin
            // default
            clean_pulse <= 1'b0;

            // if current sampled level != stable level, start counting
            if (btn_level != stable_level) begin
                if (cnt == CNT_MAX) begin
                    // accept new stable level
                    stable_level <= btn_level;
                    cnt          <= 20'd0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end else begin
                cnt <= 20'd0;
            end

            // edge detect on stable_level (press = 0 -> 1)
            prev_stable_level <= stable_level;
            if (stable_level && !prev_stable_level) begin
                clean_pulse <= 1'b1;
            end
        end
    end

endmodule