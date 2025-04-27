// Данный модуль проверяет символ на совпадение с паттерном, в нем ничего менять не нкжно

module ascii_type_detector (
  input wire [7:0] ascii_char,
  output reg small_letter, // Строчная буква (a-z)
  output reg capital_letter, // Заглавная буква (A-Z)
  output reg number, // Цифра (0-9)
  output reg hex_digit, // Шестнадцатеричная цифра (0-9, A-F, a-f)
  output reg punctuation_basic, // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
  output reg punctuation_finance, // Финансовые символы (#, $, %, &, @)
  output reg parentheses, // Скобки ((, ), [, ])
  output reg curly_braces, // Фигурные скобки ({, }) - добавлено
  output reg math_symbol, // Математические символы (+, -, *, /, \, =, <, >)
  output reg whitespace, // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
  output reg vowel, //Гласные буквы [aeiouAEIOU]
  output reg consonant, // Согласные буквы 
  output reg start_stop, //Начало и конец строки (\0)
  output reg other // Другие символы
);

  always @(*) begin
    small_letter = 1'b0;
    capital_letter = 1'b0;
    number = 1'b0;
    hex_digit = 1'b0;
    punctuation_basic = 1'b0;
    punctuation_finance = 1'b0;
    parentheses = 1'b0;
    curly_braces = 1'b0;
    math_symbol = 1'b0;
    whitespace = 1'b0;
    vowel = 1'b0;
    start_stop = 1'b0;
    other = 1'b0;
    consonant = 1'b0;
    if (ascii_char >= 8'h61 && ascii_char <= 8'h7a) small_letter = 1'b1;
    if (ascii_char >= 8'h41 && ascii_char <= 8'h5a) capital_letter = 1'b1;
    if (ascii_char >= 8'h30 && ascii_char <= 8'h39) number = 1'b1;
    if (ascii_char >= 8'h41 && ascii_char <= 8'h46) hex_digit = 1'b1;
    if (ascii_char >= 8'h61 && ascii_char <= 8'h66) hex_digit = 1'b1;
    if (number)                                     hex_digit = 1'b1; // эта строка добавлена, а то 0-9 не считаютсяя hex_digit
    if (ascii_char == 8'h2E || ascii_char == 8'h2C || ascii_char == 8'h3A || ascii_char == 8'h3B || ascii_char == 8'h21 || ascii_char == 8'h3F || ascii_char == 8'h27 || ascii_char == 8'h22) punctuation_basic = 1'b1;
    if (ascii_char == 8'h23 || ascii_char == 8'h24 || ascii_char == 8'h25 || ascii_char == 8'h26 || ascii_char == 8'h40) punctuation_finance = 1'b1;
    if (ascii_char == 8'h28 || ascii_char == 8'h29 || ascii_char == 8'h5B || ascii_char == 8'h5D) parentheses = 1'b1;
    if (ascii_char == 8'h7B || ascii_char == 8'h7D) curly_braces = 1'b1;
    if (ascii_char == 8'h2B || ascii_char == 8'h2D || ascii_char == 8'h2A || ascii_char == 8'h2F || ascii_char == 8'h5C || ascii_char == 8'h3D || ascii_char == 8'h3C || ascii_char == 8'h3E) math_symbol = 1'b1;
    if (ascii_char == 8'h20 || ascii_char == 8'h09 || ascii_char == 8'h0A || ascii_char == 8'h0D) whitespace = 1'b1;
    if (ascii_char == 8'h61 || ascii_char == 8'h65 || ascii_char == 8'h69 || ascii_char == 8'h6f || ascii_char == 8'h75 || ascii_char == 8'h41 || ascii_char == 8'h45 || ascii_char == 8'h49 || ascii_char == 8'h4f || ascii_char == 8'h55) vowel = 1'b1;
    if (!(small_letter | capital_letter | number | hex_digit | punctuation_basic | punctuation_finance | parentheses | curly_braces | math_symbol | whitespace)) other = 1'b1;
    if (ascii_char == 8'h0 || ascii_char == 8'h0A) start_stop = 1'b1;
    if (((small_letter||capital_letter)&&!vowel)) consonant = 1'b1;
  end
endmodule