module traffic_light_controller (
    input wire clk,
    input wire reset,
    output reg [1:0] NS_light,
    output reg [1:0] EW_light
);

    parameter [1:0] NS_GREEN_EW_RED   = 2'b00;
    parameter [1:0] NS_YELLOW_EW_RED  = 2'b01;
    parameter [1:0] NS_RED_EW_GREEN   = 2'b10;
    parameter [1:0] NS_RED_EW_YELLOW = 2'b11;

    parameter [1:0] RED    = 2'b00;
    parameter [1:0] YELLOW = 2'b01;
    parameter [1:0] GREEN  = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= NS_GREEN_EW_RED;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            NS_GREEN_EW_RED:   next_state = NS_YELLOW_EW_RED;
            NS_YELLOW_EW_RED:  next_state = NS_RED_EW_GREEN;
            NS_RED_EW_GREEN:   next_state = NS_RED_EW_YELLOW;
            NS_RED_EW_YELLOW:  next_state = NS_GREEN_EW_RED;
            default:           next_state = NS_GREEN_EW_RED;
        endcase
    end

    always @(*) begin
        NS_light = RED;
        EW_light = RED;

        case (state)
            NS_GREEN_EW_RED: begin
                NS_light = GREEN;
                EW_light = RED;
            end
            NS_YELLOW_EW_RED: begin
                NS_light = YELLOW;
                EW_light = RED;
            end
            NS_RED_EW_GREEN: begin
                NS_light = RED;
                EW_light = GREEN;
            end
            NS_RED_EW_YELLOW: begin
                NS_light = RED;
                EW_light = YELLOW;
            end
            default: begin
                NS_light = RED;
                EW_light = RED;
            end
        endcase
    end

endmodule