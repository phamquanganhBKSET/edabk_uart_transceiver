//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: edabk_transmitter_datapath
//    Author: anhpq0
//    Date: 26/01/2022
//    Modify: 27/02/2022
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module edabk_transmitter_datapath #(
  parameter CLK_FREQ    = `CFG_CLK_FREQ                              , // Clock frequency
  parameter CLK_DIV     = `CFG_CLK_DIV                               , // Number of bclks for each data bit
  parameter BAUDRATE    = `CFG_BAUDRATE                              , // Baud rate
  parameter BAUD_WIDTH  = $clog2((CLK_FREQ * 2)/(CLK_DIV * BAUDRATE)), // Number of bits which is used to repressent BAURATE
  parameter DATA_WIDTH  = `CFG_DATA_WIDTH                            , // Number of bits which is transmitted
  parameter COUNT_WIDTH = $clog2(CLK_DIV)                              // Number of bits which is used to repressent DATA_WIDTH
)
(
  input                   bclk   ,  // Baud clock signal
  input                   reset_n,  // Asynchronous reset active low
  input  [DATA_WIDTH-1:0] tx_in  ,  // Data in
  input                   parity ,  // Determine whether the frame has parity bit or not
  input                   shift  ,  // Shift datareg
  input                   load   ,  // Load data to datareg
  input                   clear  ,  // Clear datareg
  output                  done   ,  // Successfully transmit a bit
  output                  tx_out    // Data out
);

  // Intenal signals and variables
  wire [DATA_WIDTH+1:0]    data_in; // data_in signal
  reg  [DATA_WIDTH+1:0]    datareg; // data stored in shift register
  reg  [COUNT_WIDTH-1:0]   count  ; // counter variable: count from 0 to CLK_DIV - 1

  //-----------------------------------------------------------------
  // Data shift register
  //-----------------------------------------------------------------
  
  always @(posedge bclk, negedge reset_n) begin : data_shift_reg
    if(~reset_n) begin
      datareg <= {(DATA_WIDTH+1){1'b1}};
    end else begin
      if (clear) begin
        datareg <= {(DATA_WIDTH+1){1'b1}};
      end
      else if (load) begin
        datareg[DATA_WIDTH:0] <= {tx_in, 1'b0};
        datareg[DATA_WIDTH+1] <= (parity == 1) ? ~(^tx_in) : 1'b1;
      end
      else if (shift) begin
        datareg <= {1'b1, datareg[DATA_WIDTH+1:1]};
      end
      else begin
        datareg <= datareg;
      end
    end
  end

  //-----------------------------------------------------------------
  // Output assignment
  //-----------------------------------------------------------------
  
  assign tx_out = datareg[0];
  assign done   = (count == CLK_DIV - 1);

  //-----------------------------------------------------------------
  // Count number of bits which were transmitted
  //-----------------------------------------------------------------
  
  always @(posedge bclk, negedge reset_n) begin : counter_block
    if(~reset_n) begin
      count <= 0;
    end else begin
      count <= (load | clear | (count == CLK_DIV - 1)) ? 0 : count + 1;
    end
  end

endmodule : edabk_transmitter_datapath