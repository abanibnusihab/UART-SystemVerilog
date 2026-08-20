module uart_tx_tb;

    //====================================================
    // Signals
    //====================================================

    logic clk;
    logic rst;
    logic tx_start;
    logic [7:0] tx_data;

    logic tx;
    logic busy;


    //====================================================
    // DUT
    //====================================================

    uart_tx #(
        .CLKS_PER_BIT(5208)
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .busy     (busy)
    );


    //====================================================
    // Clock
    // 50 MHz
    //====================================================

    initial begin
        clk = 0;
    end

    always #10 clk = ~clk;


    //====================================================
    // Reset
    //====================================================

    initial begin
        rst = 1;

        #100;

        rst = 0;
    end


    //====================================================
    // Send one byte
    //====================================================

    task send_byte(input logic [7:0] data);

        begin

            // Wait until UART is free
            wait(busy == 0);

            // Put data on UART input
            tx_data = data;

            // Request transmission
            tx_start = 1;

            // Wait one clock cycle
            @(posedge clk);

            // Remove start request
            tx_start = 0;

            // Wait until UART starts transmitting
            wait(busy == 1);

            // Wait until UART finishes
            wait(busy == 0);

        end

    endtask


    //====================================================
    // Check one UART frame
    //====================================================

    task check_byte(input logic [7:0] expected);

        logic [7:0] received;
        integer i;

        begin

            // Wait for start bit
            @(negedge tx);

            // Move to middle of start bit
            #(5208 * 20 / 2);

            // Check start bit
            if (tx !== 1'b0) begin
                $display("FAIL: Start bit incorrect");
            end

            // Move to middle of first data bit
            #(5208 * 20);

            // Receive 8 data bits
            for (i = 0; i < 8; i = i + 1) begin

                received[i] = tx;

                #(5208 * 20);

            end

            // Check received data
            if (received === expected) begin
                $display("PASS: Expected = 0x%02h, Received = 0x%02h",
                         expected, received);
            end
            else begin
                $display("FAIL: Expected = 0x%02h, Received = 0x%02h",
                         expected, received);
            end

            // Check stop bit
            if (tx !== 1'b1) begin
                $display("FAIL: Stop bit incorrect");
            end
            else begin
                $display("PASS: Stop bit correct");
            end

        end

    endtask


    //====================================================
    // Test sequence
    //====================================================

    initial begin

        tx_start = 0;
        tx_data  = 8'h00;

        // Wait for reset
        #120;


        $display("--------------------------------");
        $display("UART TASK 5 VERIFICATION START");
        $display("--------------------------------");


        // Test 1
        $display("TEST 1: 0x41");
        fork
            send_byte(8'h41);
            check_byte(8'h41);
        join


        // Test 2
        $display("TEST 2: 0x42");
        fork
            send_byte(8'h42);
            check_byte(8'h42);
        join


        // Test 3
        $display("TEST 3: 0x00");
        fork
            send_byte(8'h00);
            check_byte(8'h00);
        join


        // Test 4
        $display("TEST 4: 0xFF");
        fork
            send_byte(8'hFF);
            check_byte(8'hFF);
        join


        // Test 5
        $display("TEST 5: 0xAA");
        fork
            send_byte(8'hAA);
            check_byte(8'hAA);
        join


        // Test 6
        $display("TEST 6: 0x55");
        fork
            send_byte(8'h55);
            check_byte(8'h55);
        join


        // Finished
        $display("--------------------------------");
        $display("UART TASK 5 VERIFICATION DONE");
        $display("--------------------------------");

        #1000;

        $finish;

    end


    //====================================================
    // Waveform
    //====================================================

    initial begin

        $dumpfile("uart.vcd");

        $dumpvars(0, uart_tx_tb);

    end

endmodule
