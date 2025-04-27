module rk_test();
    localparam UART_TX_baud = 20,
               freq = 200,
               TR = 10;
    reg clk = 0;
    reg rst;
    reg [7:0] ascii_char;
    reg ascii_valid;
    wire sequence_valid;
    wire output_strobe;
    always #1 clk = !clk;
    verify #(.UART_TX_baud(20), .freq(200)) 
        mverify ( //!
        .clk(clk),
        .rst(rst),
        .ascii_char(ascii_char),
        .char_valid(ascii_valid),
        .sequence_valid(sequence_valid),
        .output_strobe(output_strobe)
    );
    task pch(input [7:0] putchar);
        begin
            ascii_char = putchar;
            #(TR-2)
            ascii_valid = 1;
            #2
            ascii_valid = 0;
        end
	endtask

    task transmit_valid();
        begin
            #TR
            pch(0);
            pch(48);//0
            pch(49);//1
            pch(50);//2
            pch(43);//+
            pch(50);//2
            pch(49);//1
            pch(48);//0
            pch(0);
            #TR;
        end
	endtask

    task transmit_unvalid();
        begin
            #TR
            pch(0);
            pch(48);//0
            pch(49);//1
            pch(50);//2
            pch(43);//+
            pch(49);//1
            pch(48);//0
            pch(0);
            #TR;
        end
    endtask

    initial begin
        $dumpvars;
        ascii_char = 0;
        ascii_valid = 0;
        rst = 1;
        #100
        rst = 0;
        #100
        transmit_valid();
        #1000
        transmit_unvalid();
        #1000
        $finish;
    end



endmodule