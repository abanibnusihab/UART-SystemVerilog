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
    // DUT - UART Transmitter
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
    // Clock Generation
    // 50 MHz clock
    // Period = 20 ns
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
    // Task: Send one byte
    //====================================================

    task send_byte(input logic [7:0] data);

        begin

            // Wait until UART is free
            wait(busy == 0);

            // Put data on input
            tx_data = data;

            // Start transmission
            tx_start = 1;

            // Keep tx_start high for one clock
            @(posedge clk);

            tx_start = 0;

            // Wait until transmission is complete
            wait(busy == 1);
            wait(busy == 0);

            // Small gap between bytes
            #100;

        end

    endtask


    //====================================================
    // Test Sequence
    //====================================================

    initial begin

        // Initial values
        tx_start = 0;
        tx_data  = 8'h00;

        // Wait for reset to finish
        #120;


        // -----------------------------------------------
        // Test 1: ASCII 'A'
        // -----------------------------------------------

        $display("TEST 1: Sending A (0x41)");

        send_byte(8'h41);


        // -----------------------------------------------
        // Test 2: ASCII 'B'
        // -----------------------------------------------

        $display("TEST 2: Sending B (0x42)");

        send_byte(8'h42);


        // -----------------------------------------------
        // Test 3: All zeros
        // -----------------------------------------------

        $display("TEST 3: Sending 0x00");

        send_byte(8'h00);


        // -----------------------------------------------
        // Test 4: All ones
        // -----------------------------------------------

        $display("TEST 4: Sending 0xFF");

        send_byte(8'hFF);


        // -----------------------------------------------
        // Test 5: Alternating bits 10101010
        // -----------------------------------------------

        $display("TEST 5: Sending 0xAA");

        send_byte(8'hAA);


        // -----------------------------------------------
        // Test 6: Alternating bits 01010101
        // -----------------------------------------------

        $display("TEST 6: Sending 0x55");

        send_byte(8'h55);


        // -----------------------------------------------
        // Test complete
        // -----------------------------------------------

        $display("--------------------------------");
        $display("ALL UART TESTS COMPLETED");
        $display("--------------------------------");

        #1000;

        $finish;

    end


    //====================================================
    // Waveform Dump
    //====================================================

    initial begin

        $dumpfile("uart.vcd");

        $dumpvars(0, uart_tx_tb);

    end

endmodule
