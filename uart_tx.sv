module uart_tx #(
    parameter integer CLKS_PER_BIT = 5208
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,

    output logic       tx,
    output logic       busy
);

    // --------------------------------
    // FSM states
    // --------------------------------
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    // --------------------------------
    // UART timing counter
    // --------------------------------
    logic [12:0] baud_count;

    // --------------------------------
    // Data bit counter
    // 0 = d0
    // 1 = d1
    // ...
    // 7 = d7
    // --------------------------------
    logic [2:0] bit_index;

    // --------------------------------
    // Stores the byte being transmitted
    // --------------------------------
    logic [7:0] data_reg;


    // ================================================
    // SEQUENTIAL LOGIC
    // ================================================
    always_ff @(posedge clk) begin

        // -----------------------------
        // RESET
        // -----------------------------
        if (rst) begin
            state      <= IDLE;
            baud_count <= 0;
            bit_index  <= 0;
            data_reg   <= 0;
        end

        // -----------------------------
        // NORMAL OPERATION
        // -----------------------------
        else begin

            case (state)

                // ====================================
                // IDLE STATE
                // ====================================
                IDLE: begin

                    if (tx_start) begin
                        data_reg   <= tx_data;
                        baud_count <= 0;
                        bit_index  <= 0;
                        state      <= START;
                    end

                end


                // ====================================
                // START STATE
                // ====================================
                START: begin

                    if (baud_count < CLKS_PER_BIT - 1) begin
                        baud_count <= baud_count + 1;
                    end

                    else begin
                        baud_count <= 0;
                        state      <= DATA;
                    end

                end


                // ====================================
                // DATA STATE
                // ====================================
                DATA: begin

                    if (baud_count < CLKS_PER_BIT - 1) begin
                        baud_count <= baud_count + 1;
                    end

                    else begin
                        baud_count <= 0;

                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end

                        else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end

                end


                // ====================================
                // STOP STATE
                // ====================================
                STOP: begin

                    if (baud_count < CLKS_PER_BIT - 1) begin
                        baud_count <= baud_count + 1;
                    end

                    else begin
                        baud_count <= 0;
                        state      <= IDLE;
                    end

                end

            endcase

        end

    end


    // ================================================
    // COMBINATIONAL OUTPUT LOGIC
    // ================================================
    always_comb begin

        // Default values
        tx   = 1'b1;
        busy = 1'b0;

        case (state)

            // --------------------------------
            // IDLE
            // --------------------------------
            IDLE: begin
                tx   = 1'b1;
                busy = 1'b0;
            end


            // --------------------------------
            // START BIT
            // --------------------------------
            START: begin
                tx   = 1'b0;
                busy = 1'b1;
            end


            // --------------------------------
            // DATA BITS
            // --------------------------------
            DATA: begin
                tx   = data_reg[bit_index];
                busy = 1'b1;
            end


            // --------------------------------
            // STOP BIT
            // --------------------------------
            STOP: begin
                tx   = 1'b1;
                busy = 1'b1;
            end

        endcase

    end

endmodule
