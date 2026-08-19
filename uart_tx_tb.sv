module uart_tx_tb;

    logic clk;
    logic rst;
    logic tx_start;
    logic [7:0] tx_data;

    logic tx;
    logic busy;

    uart_tx #(
        .CLKS_PER_BIT(5208)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy)
    );

    // Start clock at 0
    initial begin
        clk = 0;
    end

    // 50 MHz clock
    always #10 clk = ~clk;

    // Reset
    initial begin
        rst      = 1;
        tx_start = 0;
        tx_data  = 0;

        #100;

        rst = 0;
    end

endmodule
