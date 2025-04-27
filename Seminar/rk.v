module verify #(parameter UART_TX_baud, freq)  ( //!
    input clk,
    input rst,
    input [7:0] ascii_char,
    input char_valid,
    output reg sequence_valid,//!
    output reg output_strobe //!
);//!
    reg [1:0] k;
    reg fl;
    wire number, math_symbol, start_stop;

    localparam cnt_val = freq/UART_TX_baud + 1;
    reg [$clog2(freq/UART_TX_baud):0] strobe_cnt;
    reg strobe_clk;
    reg need_strobe_out;
    // reg LWV;

    localparam  IDLE        = 'b000,
                START_STOP  = 'b001,
                NUMBER      = 'b010,
                MATH_SYMBOL = 'b011,
                ERROR       = 'b100;
    reg [2:0] state;
    reg [2:0] next_state;

    ascii_type_detector ascii_detector(
        .ascii_char(ascii_char),
        .number(number),
        .math_symbol(math_symbol),
        .start_stop(start_stop)
    );

    always @(posedge clk)
        if (rst) begin
            state <= 0;//!
        end else 
            if (((state == START_STOP) && fl)||(state == ERROR)||rst||char_valid)
                case (state)
                    IDLE        : state <= start_stop ? START_STOP : IDLE;
                    START_STOP  : state <= fl//!
                                                ? IDLE
                                                :   number 
                                                    ? NUMBER
                                                    : ERROR;
                    NUMBER      : state <= k == 2//! 
                                                ?   !fl && math_symbol//!
                                                    ? MATH_SYMBOL
                                                    :   fl && start_stop//!
                                                        ? START_STOP
                                                        : ERROR
                                                :   number
                                                    ? NUMBER
                                                    : ERROR;
                    MATH_SYMBOL : state <= number ? NUMBER : ERROR;
                    default     : state <= IDLE;
                endcase

    // assign state =  ((state == START_STOP) && fl)  // Переключаем state без наличия новой буквы
    //                ||(state == ERROR)              // Переключаем state без наличия новой буквы
    //                || rst //!
    //                || /*LWV*/char_valid ? next_state : state;

    always @(posedge clk)
        if (rst) begin
            // LWV <= 0;
            k <= 0;
            strobe_clk <= 0;
            strobe_cnt <= cnt_val;
            sequence_valid <= 0;
            need_strobe_out <= 0; //!
            fl <= 0;
        end else begin
            // LWV <= char_valid;
            strobe_cnt <= strobe_cnt - 1;
            strobe_clk <= 0;//!
            if (!strobe_cnt) begin
                strobe_clk <= 1;
                strobe_cnt <= cnt_val;
            end
            if (char_valid) begin
                if (state == NUMBER)
                    k <= k + 1;
                else
                    k <= 0;
                if (state == MATH_SYMBOL)
                    fl <= 1; //!                
            end
            if ((state == ERROR || state == IDLE) && fl) begin
                fl <= 0; //!
                need_strobe_out <= 1;
                if (state == IDLE)
                    sequence_valid <= 1; //!
            end
            if (need_strobe_out && strobe_clk) begin
                //sequence_valid <= 0; //!
                need_strobe_out <= 0; //!
                output_strobe <= 1;
            end else 
                output_strobe <= 0;
            if (sequence_valid&&!need_strobe_out) //!
                sequence_valid <= 0;
        end
endmodule