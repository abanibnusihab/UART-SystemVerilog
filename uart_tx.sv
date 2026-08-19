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

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    // UART timing counter
    logic [12:0] baud_count;

    // Selects which data bit is being transmitted
    logic [2:0] bit_index;

    // Stores the byte currently being transmitted
    logic [7:0] data_reg;


    // Sequential logic
    always_ff @(posedge clk) begin

        if (rst) begin
            state      <= IDLE;
            baud_count <= 0;
            bit_index  <= 0;
            data_reg   <= 0;
        end

        else begin

            case (state)

                // -------------------------
                // IDLE STATE
                // -------------------------
                IDLE: begin

                    if (tx_start) begin
                        data_reg   <= tx_data;
                        baud_count <= 0;
                        bit_index  <= 0;
                        state      <= START;
                    end

                end


                // -------------------------
                // START STATE
                // -------------------------
                START: begin

                    if (baud_count < CLKS_PER_BIT - 1) begin
                        baud_count <= baud_count + 1;
                    end

                    else begin
                        baud_count <= 0;
                        state      <= DATA;
                    end

                end


                // -------------------------
                // DATA STATE
                // -------------------------
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


                // -------------------------
                // STOP STATE
                // -------------------------
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


    // TX output logic
    always_comb begin

        // UART idle level
        tx = 1'b1;

        case (state)

            IDLE: begin
                tx = 1'b1;
            end

            START: begin
                tx = 1'b0;
            end

            DATA: begin
                tx = data_reg[bit_index];
            end

            STOP: begin
                tx = 1'b1;
            end

        endcase

    end

endmodule
