//  Данный модуль работает на вывод информации, в нем ничего менять не нужно

module verify #(parameter UART_TX_baud, freq)  (
    input clk,
    input rst,
    input [7:0] ascii_char,
    input char_valid,
    output reg sequence_valid,
    output reg output_strobe
);
    wire    start_stop,         // Начало и конец строки (\0)
            small_letter,       // Строчная буква (a-z)
            capital_letter,     // Заглавная буква (A-Z)
            number,             // Цифра (0-9)
            hex_digit,          // Шестнадцатеричная цифра (0-9, A-F, a-f)
            punctuation_basic,  // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
            punctuation_finance, // Финансовые символы (#, $, %, &, @)
            parentheses,        // Скобки ((, ), [, ])
            curly_braces,       // Фигурные скобки ({, }) - добавлено
            math_symbol,        // Математические символы (+, -, *, /, \, =, <, >)
            whitespace,         // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
            vowel,              // Гласные буквы [aeiouAEIOU]
            consonant,          // Согласные буквы
            other;              // Другие символы

    localparam cnt_val = freq/UART_TX_baud + 1;
    reg [$clog2(freq/UART_TX_baud):0] strobe_cnt;
    reg strobe_clk;
    reg need_strobe_out;
    reg already_was;
    reg error_verify;

    
    reg [3:0] state;
    
    tsk prob(
        .state(state),
        .rst(rst),
        .clk(clk),
        .valid(char_valid),
        .next_state(state),
        .error_verify(error_verify),

        .start_stop(start_stop),                 // Начало и конец строки (\0)
        .small_letter(small_letter),             // Строчная буква (a-z)
        .capital_letter(capital_letter),         // Заглавная буква (A-Z)
        .number(number),                         // Цифра (0-9)
        .hex_digit(hex_digit),                   // Шестнадцатеричная цифра (0-9, A-F, a-f)
        .punctuation_basic(punctuation_basic),   // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
        .punctuation_finance(punctuation_finance), // Финансовые символы (#, $, %, &, @)
        .parentheses(parentheses),               // Скобки ((, ), [, ])
        .curly_braces(curly_braces),             // Фигурные скобки ({, }) - добавлено
        .math_symbol(math_symbol),               // Математические символы (+, -, *, /, \, =, <, >)
        .whitespace(whitespace),                 // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
        .vowel(vowel),                           // Гласные буквы [aeiouAEIOU]
        .consonant(consonant),                   // Согласные буквы
        .other(other)                            // Другое (подразумевается из строки 'other;')
    );


    ascii_type_detector ascii_detector(
        .ascii_char(ascii_char),
        .start_stop(start_stop),                 // Начало и конец строки (\0)
        .small_letter(small_letter),             // Строчная буква (a-z)
        .capital_letter(capital_letter),         // Заглавная буква (A-Z)
        .number(number),                         // Цифра (0-9)
        .hex_digit(hex_digit),                   // Шестнадцатеричная цифра (0-9, A-F, a-f)
        .punctuation_basic(punctuation_basic),   // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
        .punctuation_finance(punctuation_finance), // Финансовые символы (#, $, %, &, @)
        .parentheses(parentheses),               // Скобки ((, ), [, ])
        .curly_braces(curly_braces),             // Фигурные скобки ({, }) - добавлено
        .math_symbol(math_symbol),               // Математические символы (+, -, *, /, \, =, <, >)
        .whitespace(whitespace),                 // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
        .vowel(vowel),                           // Гласные буквы [aeiouAEIOU]
        .consonant(consonant),                   // Согласные буквы
        .other(other)                            // Другое (подразумевается из строки 'other;')
    );

    localparam IDLE =  4'b0000,
               START = 4'b0001,
               STOP =  4'b0010,
               ERROR = 4'b0011;

    always @(posedge clk)
        if (rst) begin
            strobe_clk <= 0;
            strobe_cnt <= cnt_val;
            sequence_valid <= 0;
            need_strobe_out <= 0;
            already_was <= 1;
            error_verify <= 0;
        end else begin
            strobe_cnt <= strobe_cnt - 1;
            strobe_clk <= 0;
            

            if (!strobe_cnt) 
            begin
                strobe_clk <= 1;
                strobe_cnt <= cnt_val;
            end
            if (state == ERROR && !already_was)
            begin
                need_strobe_out <= 1;
                already_was <= 1;
                error_verify <= start_stop;
            end
            if (state == IDLE && !already_was)
            begin
                need_strobe_out <= 1;
                sequence_valid <= 1;
                already_was <= 1;
            end
            if (state != ERROR && state != IDLE) 
                already_was <= 0;
            if (need_strobe_out && strobe_clk) 
            begin
                need_strobe_out <= 0;
                output_strobe <= 1;
                already_was <= 1;
            end 
            else 
                output_strobe <= 0;

            if (state != ERROR)
                error_verify <= 0;

            if (sequence_valid&&!need_strobe_out)
                sequence_valid <= 0;

        end
endmodule;