module ascii_type_detector(
        input [7:0] ascii_char,
        output number,
        output math_symbol,
        output start_stop
    );
    assign number = (48 <= ascii_char && ascii_char <= 57);//0123456789
    assign math_symbol = (ascii_char == 42) // *
                      || (ascii_char == 43) // +
                      || (ascii_char == 47) // /
                      || (ascii_char == 60) // <
                      || (ascii_char == 61) // =
                      || (ascii_char == 62);// >
    assign start_stop = (ascii_char == 0);

endmodule