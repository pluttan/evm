// Модуль теста автомата
// Начиная с двойной черты ====== и заканчивая одинарной ------- идет код, 
// который необходимо заменить в соответствии с вариантом


module rk_test();

    // =========================================
    // Параметры тестирования
    // UART_RX_BAUD
    // UART_TX_baud
    // freq
    localparam UART_RX_BAUD = 20,
               UART_TX_baud = 20,
               freq = 200,
    // -----------------------------------------
               TR = freq/UART_RX_BAUD;
    
    
    reg clk = 0;
    reg rst;
    reg [7:0] ascii_char;
    reg ascii_valid;
    wire sequence_valid;
    wire output_strobe;
    
    always #1 clk = !clk;

    task cntclk(input [7:0] cnt);
        for (integer i = 0; i < cnt; i = i + 1) @(posedge clk);
    endtask
    
    task pch(input [7:0] putchar);
        begin
            ascii_char = putchar;
            cntclk(TR-1);
            ascii_valid = 1;
            cntclk(1);
            ascii_valid = 0;
        end
    endtask
    
    task transmit(input [100*8-1:0] str);
        begin
            integer i;
            integer len;
            len = 0;
            for (i = 0; i < 100; i = i + 1) begin
                if (str[8*i +: 8] != 0) begin
                    len = len + 1;
                end
            end
            pch(0);
            for (i = len-1; i >= 0; i = i - 1) begin
                pch(str[8*i +: 8]);
            end
            pch(0);
            cntclk(100);
        end
    endtask


    
    
    verify #(.UART_TX_baud(UART_TX_baud), .freq(freq)) 
        mverify (
        .clk(clk),
        .rst(rst),
        .ascii_char(ascii_char),
        .char_valid(ascii_valid),
        .sequence_valid(sequence_valid),
        .output_strobe(output_strobe)
    );

    initial begin
        $dumpvars;
        ascii_char = 0;
        ascii_valid = 0;
        rst = 1;
        cntclk(100);
        rst = 0;
        cntclk(100);
        // =========================================
        // transmit передает строку в виде \0 + параметр + \0 и делает небольшую задержку после
        // Для проверки автомата можно использовать одну правильную и одну неправильную последовательность
        transmit("(+12)");
        transmit("(+1A)");
        // -----------------------------------------
        cntclk(200);
        $finish;
    end
endmodule