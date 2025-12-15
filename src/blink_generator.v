// Blink generator for Night Mode
//============================================================
module blink_generator #(
    parameter integer HALF_PERIOD_TICKS = 25_000_000 // 0.5s @ 50MHz → 1Hz blink
)(
    input  wire clk,
    input  wire reset_n,      // active-low
    input  wire enable,       // blink_enable from FSM
    output reg  blink_out     // connect to FSM's yellow LED logic
);

    reg [25:0] cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cnt      <= 26'd0;
            blink_out<= 1'b0;
        end else if (enable) begin
            if (cnt == HALF_PERIOD_TICKS - 1) begin
                cnt       <= 26'd0;
                blink_out <= ~blink_out;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end else begin
            cnt       <= 26'd0;
            blink_out <= 1'b0;
        end
    end

endmodule