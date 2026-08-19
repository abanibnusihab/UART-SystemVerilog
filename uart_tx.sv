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

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    logic [12:0] baud_count;
    logic [2:0]  bit_index;
    logic [7:0]  data_reg;
    
always_ff @(posedge clk) begin

    if (rst) begin
        state      <= IDLE;
        baud_count <= 0;
        bit_index  <= 0;
        data_reg   <= 0;
    end
    else begin

        case (state)

            IDLE: begin

                if (tx_start) begin
                    data_reg   <= tx_data;
                    baud_count <= 0;
                    bit_index  <= 0;
                    state      <= START;
                end

            end

        endcase

    end

end
endmodule
