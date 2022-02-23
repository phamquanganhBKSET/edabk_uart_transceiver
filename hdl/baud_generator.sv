//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: baud_generator
//    Author: anhpq0
//    Date: 25/01/2022
//    Modify: 
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module baud_generator #(
  parameter CLK_FREQ   = `CFG_CLK_FREQ                              , // Clock frequency
  parameter CLK_DIV    = `CFG_CLK_DIV                               , // Number of bclks for each data bit
  parameter BAUDRATE   = `CFG_BAUDRATE                              , // Baud rate
  parameter BAUD_WIDTH = $clog2((CLK_FREQ * 2)/(CLK_DIV * BAUDRATE))  // Number of bits which is used to repressent BAURATE
)
(
  input        clk     , // Clock signal
  input        reset_n , // Asynchronous reset active low
  input  [2:0] baudrate, // Baudrate selection
  output reg   bclk      // Baudrate clock
);

  reg [BAUD_WIDTH-1:0] divisor; // divisor
  wire                 tick   ; // tick signal
  reg [BAUD_WIDTH-1:0] count  ; // counter variable

  // Select divisor
  always @(baudrate) begin : divisor_select
    case (baudrate)
      3'b000 : begin
        divisor = `DIVISOR_1200;
      end

      3'b001 : begin
        divisor = `DIVISOR_2400;
      end

      3'b010 : begin
        divisor = `DIVISOR_4800;
      end

      3'b011 : begin
        divisor = `DIVISOR_9600;
      end

      3'b100 : begin
        divisor = `DIVISOR_19200;
      end

      3'b101 : begin
        divisor = `DIVISOR_38400;
      end

      3'b110 : begin
        divisor = `DIVISOR_57600;
      end

      3'b111 : begin
        divisor = `DIVISOR_115200;
      end

      default : begin
        divisor = 0;
      end
    endcase
  end : divisor_select

  // tick signal asignment
  assign tick = (divisor == count);

  // counter variable
  always @(posedge clk, negedge reset_n) begin : count_process
    if (~reset_n) begin
      count <= 0;
    end
    else begin
      count <= (tick == 0) ? count + 1 : 0;
    end
  end : count_process

  // bclk assignment
  always @(posedge clk, negedge reset_n) begin : bclk_assignment
    if (~reset_n) begin
      bclk <= 0;
    end
    else begin
      bclk <= (tick == 0) ? bclk : ~bclk;
    end
  end : bclk_assignment

endmodule : baud_generator