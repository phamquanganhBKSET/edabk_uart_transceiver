//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: edabk_receiver_controller
//    Author: anhpq0
//    Date: 26/01/2022
//    Modify: 
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module edabk_receiver_controller #(
  parameter CLK_FREQ    = `CFG_CLK_FREQ                              , // Clock frequency
  parameter CLK_DIV     = `CFG_CLK_DIV                               , // Number of bclks for each data bit
  parameter BAUDRATE    = `CFG_BAUDRATE                              , // Baud rate
  parameter BAUD_WIDTH  = $clog2((CLK_FREQ * 2)/(CLK_DIV * BAUDRATE)), // Number of bits which is used to repressent BAURATE
  parameter DATA_WIDTH  = `CFG_DATA_WIDTH                              // Number of bits which is transmitted
)
(
  input bclk   ,  // Clock
  input reset_n,  // Asynchronous reset active low
  
);

endmodule : edabk_receiver_controller