// Модуль с заданием по варианту
// Начиная с двойной черты ====== и заканчивая одинарной ------- идет код, 
// который необходимо заменить в соответствии с вариантом

module tsk(
    input [3:0] state,
    input rst,
    input clk,
    input valid,
    input error_verify,
    output reg [3:0] next_state,

    input   start_stop,         // Начало и конец строки (\0)
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
            other               // Другие символы
);

    

    localparam // Общие состояния
               IDLE =  0, 
               START = 1,
               STOP =  2,
               ERROR = 3,

               // =========================================
               // Состояния автомата по варианту (4 - состояние в которое необходимо попасть со старта)
               CURLYBRACES1  = 4,
               HEXDIGIT1 = 5,
               MATHSYMBOL = 6,
               HEXDIGIT2 = 7,
               CURLYBRACES2 = 8;
               // -----------------------------------------

    // =========================================
    // Счетчики
    reg [2:0] k;
    // -----------------------------------------
               

    always @(posedge clk)
        if (rst) begin
            next_state <= 0;
            // =========================================
            // Обнулить счетчики
            k = 0;
            // -----------------------------------------
        end 
        else 
        begin
            // Автомат переходит в следующее состояние если: 
            // state = STOP (не ждем следующего символа, сразу выводим valid)
            // state = ERROR тут 2 случая: если в ошибку мы попали по недописанной строке, 
            //                             то нам не нужно ждать \0 так как по этому стопу 
            //                             мы в нее попали
            //                             если ошибка внутри строки нам нужно ждать \0, 
            //                             иначе мы стоповый байт примем за стартовый
            // valid = 1 Для всех остальных состояний автомата переход осуществляется 
            //           в зависимости от следующего символа, поэтому переходим только когда он принят
            if ((state == STOP)||valid||(state == ERROR))
            begin
                // =========================================
                // Логика счетчиков
                // СЧЕТЧИКИ СЧИТАЮТСЯ С 0, т.е. если вам нужно 2-3 символа, то 1 <= cnt <= 2 
                k <= (state == HEXDIGIT1 || state == HEXDIGIT2) ? k + 1 : 0;
                // -----------------------------------------

                // Логика переходов
                case (state)
                    // Переходим из общих состояний
                    IDLE        : next_state <= start_stop ? START : IDLE;
                    START       : next_state <= 
                                                // =========================================
                                                // Стартовое условие (после \0)
                                                curly_braces 
                                                // -----------------------------------------
                                                ? 4 : ERROR;
                    ERROR       : next_state <= (error_verify||(start_stop&&valid)) ? IDLE : ERROR;   
                    default     : next_state <= IDLE; // STOP ведет в IDLE

                    // =========================================
                    // Логика переходов автомата по варианту
                    CURLYBRACES1: next_state <= hex_digit ? HEXDIGIT1 : ERROR;
                    HEXDIGIT1: next_state <= (k==3 && math_symbol) ? MATHSYMBOL : (k < 3 && hex_digit) ? HEXDIGIT1 : ERROR;
                    MATHSYMBOL: next_state <= hex_digit ? HEXDIGIT2 : ERROR;
                    HEXDIGIT2: next_state <= (k==3 && curly_braces) ? CURLYBRACES2 : (k < 3 && hex_digit) ? HEXDIGIT2 : ERROR;
                    CURLYBRACES2: next_state <= start_stop ? STOP : ERROR;
                    // -----------------------------------------

                endcase
            end
        end

endmodule