`timescale 1ns/1ps

module tb_traffic_light;
    reg clk;
    reg reset;
    wire [1:0] NS_light;
    wire [1:0] EW_light;
    wire [1:0] state;

    localparam [1:0] STATE_0 = 2'b00;
    localparam [1:0] STATE_1 = 2'b01;
    localparam [1:0] STATE_2 = 2'b10;
    localparam [1:0] STATE_3 = 2'b11;

    localparam [1:0] RED    = 2'b00;
    localparam [1:0] YELLOW = 2'b01;
    localparam [1:0] GREEN  = 2'b10;

    integer i;
    integer passed;
    integer failed;
    reg reset_ok;
    reg [3:0] output_ok;
    reg sequence_ok;
    reg no_conflicting_green;
    reg legal_outputs;

    traffic_light_controller dut (
        .clk(clk),
        .reset(reset),
        .NS_light(NS_light),
        .EW_light(EW_light)
    );

    assign state = dut.state;

    always #5 clk = ~clk;

    task check_sample;
        input [1:0] expected_state;
        input [1:0] expected_ns;
        input [1:0] expected_ew;
        begin
            if (state !== expected_state ||
                NS_light !== expected_ns || EW_light !== expected_ew)
                sequence_ok = 1'b0;

            if (NS_light === GREEN && EW_light === GREEN)
                no_conflicting_green = 1'b0;

            if (!((NS_light === RED || NS_light === YELLOW || NS_light === GREEN) &&
                  (EW_light === RED || EW_light === YELLOW || EW_light === GREEN)))
                legal_outputs = 1'b0;

            case (expected_state)
                STATE_0: if (NS_light === GREEN && EW_light === RED) output_ok[0] = 1'b1;
                STATE_1: if (NS_light === YELLOW && EW_light === RED) output_ok[1] = 1'b1;
                STATE_2: if (NS_light === RED && EW_light === GREEN) output_ok[2] = 1'b1;
                STATE_3: if (NS_light === RED && EW_light === YELLOW) output_ok[3] = 1'b1;
            endcase
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        passed = 0;
        failed = 0;
        reset_ok = 1'b0;
        output_ok = 4'b0000;
        sequence_ok = 1'b1;
        no_conflicting_green = 1'b1;
        legal_outputs = 1'b1;

        $dumpfile("simulation/traffic_light_tb.vcd");
        $dumpvars(0, tb_traffic_light);
        $timeformat(-9, 0, " ns", 6);
        $monitor("time=%0t reset=%b state=%b NS=%b EW=%b",
                 $time, reset, state, NS_light, EW_light);

        #1;
        if (state === STATE_0 && NS_light === GREEN && EW_light === RED) begin
            reset_ok = 1'b1;
            check_sample(STATE_0, GREEN, RED);
        end

        #9 reset = 1'b0;

        for (i = 1; i <= 8; i = i + 1) begin
            @(posedge clk);
            #1;
            case (i % 4)
                1: check_sample(STATE_1, YELLOW, RED);
                2: check_sample(STATE_2, RED, GREEN);
                3: check_sample(STATE_3, RED, YELLOW);
                0: check_sample(STATE_0, GREEN, RED);
            endcase
        end

        $display("");
        $display("Self-check summary (two complete FSM cycles):");

        if (reset_ok) begin
            $display("PASS: asynchronous reset selects STATE 0");
            passed = passed + 1;
        end else begin
            $display("FAIL: asynchronous reset selects STATE 0");
            failed = failed + 1;
        end

        if (output_ok[0]) begin
            $display("PASS: STATE 0 outputs NS=GREEN, EW=RED");
            passed = passed + 1;
        end else begin
            $display("FAIL: STATE 0 outputs NS=GREEN, EW=RED");
            failed = failed + 1;
        end

        if (output_ok[1]) begin
            $display("PASS: STATE 1 outputs NS=YELLOW, EW=RED");
            passed = passed + 1;
        end else begin
            $display("FAIL: STATE 1 outputs NS=YELLOW, EW=RED");
            failed = failed + 1;
        end

        if (output_ok[2]) begin
            $display("PASS: STATE 2 outputs NS=RED, EW=GREEN");
            passed = passed + 1;
        end else begin
            $display("FAIL: STATE 2 outputs NS=RED, EW=GREEN");
            failed = failed + 1;
        end

        if (output_ok[3]) begin
            $display("PASS: STATE 3 outputs NS=RED, EW=YELLOW");
            passed = passed + 1;
        end else begin
            $display("FAIL: STATE 3 outputs NS=RED, EW=YELLOW");
            failed = failed + 1;
        end

        if (sequence_ok) begin
            $display("PASS: FSM follows the required sequence for two cycles");
            passed = passed + 1;
        end else begin
            $display("FAIL: FSM follows the required sequence for two cycles");
            failed = failed + 1;
        end

        if (no_conflicting_green) begin
            $display("PASS: NS and EW are never green simultaneously");
            passed = passed + 1;
        end else begin
            $display("FAIL: NS and EW are never green simultaneously");
            failed = failed + 1;
        end

        if (legal_outputs) begin
            $display("PASS: no unexpected output combinations observed");
            passed = passed + 1;
        end else begin
            $display("FAIL: no unexpected output combinations observed");
            failed = failed + 1;
        end

        $display("RESULT: %0d passed, %0d failed", passed, failed);
        if (failed != 0)
            $fatal(1, "Traffic light controller testbench failed");
        $finish;
    end
endmodule