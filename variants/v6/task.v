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

    input   start_stop,         //Начало и конец строки (\0)
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
            vowel,              //Гласные буквы [aeiouAEIOU]
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
               NUMBER1 = 4, 
               MATH_SYMBOL =  5,
               NUMBER2 = 6;
               // -----------------------------------------

    // =========================================
    // Счетчики
    reg [1:0] k;
    // -----------------------------------------
               

    always @(posedge clk)
        if (rst) begin
            next_state <= 0;
            k <= 0;
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
                k <= (state == NUMBER1)||(state == NUMBER2) ? k+1 : 0;
                // -----------------------------------------

                // Логика переходов
                case (state)
                    // Переходим из общих состояний
                    IDLE        : next_state <= start_stop ? START : IDLE;
                    START       : next_state <= number ? 4 : ERROR;
                    ERROR       : next_state <= (error_verify||(start_stop&&valid)) ? IDLE : ERROR;  
                    default     : next_state <= IDLE; // STOP и ERROR ведут в IDLE

                    // =========================================
                    // Логика переходов автомата по варианту
                    NUMBER1     : next_state <= k == 2 ? (math_symbol ? MATH_SYMBOL : ERROR) : (number ? NUMBER1 : ERROR);
                    MATH_SYMBOL : next_state <= number ? NUMBER2 : ERROR;
                    NUMBER2     : next_state <= k == 2 ? (start_stop ? STOP : ERROR) : (number ? NUMBER2 : ERROR);
                    // -----------------------------------------

                endcase
            end
        end

endmodule