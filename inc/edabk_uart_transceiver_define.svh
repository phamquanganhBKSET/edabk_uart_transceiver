//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Author: anhpq0
//    Date: 25/01/2022
//    Modify: 
//-------------------------------------------------------------------------------------------------------------------

`define CFG_CLK_FREQ      100000000                                   // Clock frequency
`define CFG_CLK_DIV       8                                           // Number of bclks for each data bit
`define CFG_BAUDRATE      9600                                        // Baud rate
`define CFG_DATA_WIDTH    8                                           // Number of bits which is transmitted
`define DIVISOR_1200      (`CFG_CLK_FREQ * 2)/(CLK_DIV * 1200  ) - 1  // Divisor for 1200 baud
`define DIVISOR_2400      (`CFG_CLK_FREQ * 2)/(CLK_DIV * 2400  ) - 1  // Divisor for 2400 baud
`define DIVISOR_4800      (`CFG_CLK_FREQ * 2)/(CLK_DIV * 4800  ) - 1  // Divisor for 4800 baud
`define DIVISOR_9600      (`CFG_CLK_FREQ * 2)/(CLK_DIV * 9600  ) - 1  // Divisor for 9600 baud
`define DIVISOR_19200     (`CFG_CLK_FREQ * 2)/(CLK_DIV * 19200 ) - 1  // Divisor for 19200 baud
`define DIVISOR_38400     (`CFG_CLK_FREQ * 2)/(CLK_DIV * 38400 ) - 1  // Divisor for 38400 baud
`define DIVISOR_57600     (`CFG_CLK_FREQ * 2)/(CLK_DIV * 57600 ) - 1  // Divisor for 57600 baud
`define DIVISOR_115200    (`CFG_CLK_FREQ * 2)/(CLK_DIV * 115200) - 1  // Divisor for 115200 baud
