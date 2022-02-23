//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: edabk_transmitter
//    Author: anhpq0
//    Date: 26/01/2022
//    Modify: 
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module edabk_transmitter #(
  parameter CLK_FREQ    = `CFG_CLK_FREQ                              , // Clock frequency
  parameter CLK_DIV     = `CFG_CLK_DIV                               , // Number of bclks for each data bit
  parameter BAUDRATE    = `CFG_BAUDRATE                              , // Baud rate
  parameter BAUD_WIDTH  = $clog2((CLK_FREQ * 2)/(CLK_DIV * BAUDRATE)), // Number of bits which is used to repressent BAURATE
  parameter DATA_WIDTH  = `CFG_DATA_WIDTH                              // Number of bits which is transmitted
)
(
  input                   bclk   ,  // Baud clock signal
  input                   reset_n,  // Asynchronous reset active low
  input                   start  ,  // Start transmission
  input  [DATA_WIDTH-1:0] tx_in  ,  // Data in
  output                  tx_out ,  // Data out
  output                  finish    // Successfully transmit DATA_WIDTH bits
);

  wire done ,
       shift,
       load ,
       clear;

  edabk_transmitter_controller uart_transmitter_controller (
    .bclk   (bclk   ),
    .reset_n(reset_n),
    .start  (start  ),
    .done   (done   ),
    .shift  (shift  ),
    .load   (load   ),
    .clear  (clear  ),
    .finish (finish ) 
  );

  edabk_transmitter_datapath uart_transmitter_datapath (
    .bclk   (bclk   ),
    .reset_n(reset_n),
    .tx_in  (tx_in  ),
    .shift  (shift  ),
    .load   (load   ),
    .clear  (clear  ),
    .done   (done   ),
    .tx_out (tx_out ) 
  );

endmodule : edabk_transmitter