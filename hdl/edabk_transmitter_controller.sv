//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: edabk_transmitter_controller
//    Author: anhpq0
//    Date: 26/01/2022
//    Modify: 27/02/2022
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module edabk_transmitter_controller #(
  parameter CLK_FREQ    = `CFG_CLK_FREQ                              , // Clock frequency
  parameter CLK_DIV     = `CFG_CLK_DIV                               , // Number of bclks for each data bit
  parameter BAUDRATE    = `CFG_BAUDRATE                              , // Baud rate
  parameter BAUD_WIDTH  = $clog2((CLK_FREQ * 2)/(CLK_DIV * BAUDRATE)), // Number of bits which is used to repressent BAURATE
  parameter DATA_WIDTH  = `CFG_DATA_WIDTH                            , // Number of bits which is transmitted
  parameter COUNT_WIDTH = $clog2(DATA_WIDTH + 2)                       // Number of bits which is used to repressent DATA_WIDTH
)
(
  input      bclk   ,  // Baud clock signal
  input      reset_n,  // Asynchronous reset active low
  input      start  ,  // Start transmission
  input      parity ,  // Determine whether the frame has parity bit or not
  input      done   ,  // Successfully transmit a bit
  output reg shift  ,  // Shift datareg
  output reg load   ,  // Load data to datareg
  output reg clear  ,  // Clear datareg
  output reg finish    // Successfully transmit DATA_WIDTH bits
);

  // Declare states
  localparam IDLE     = 2'b00,
             TRANSMIT = 2'b01,
             WAIT     = 2'b10;

  // Intenal signals and variables
  reg [1:0]             current_state, 
                        next_state   ; // Determine state
  reg [COUNT_WIDTH-1:0] data_count   ; // counter variable: count from 0 to count_to
  reg [COUNT_WIDTH-1:0] count_to     ; // Declare the maximum value of data_count

  //-----------------------------------------------------------------
  // Clocked Block for ASMD
  //-----------------------------------------------------------------
  
  always @(posedge bclk, negedge reset_n) begin : clocked_block
    if(~reset_n) begin
      // Reset current_state
      current_state <= IDLE;

      // Reset values
      shift         <= 1'b0;
      load          <= 1'b0;
      clear         <= 1'b1;
      finish        <= 1'b0;
      data_count    <= 0   ;
      count_to      <= 0   ;
    end else begin
      // Update state
      current_state <= next_state;
    end
  end

  //-----------------------------------------------------------------
  // Next State Block for ASMD
  //-----------------------------------------------------------------
  
  always @(
    start        ,
    done         ,
    shift        ,
    load         ,
    clear        ,
    data_count   ,
    current_state 
  )
  begin : next_state_block
    case (current_state)
      IDLE : begin
        if (start) begin
          next_state = TRANSMIT;
        end
        else begin
          next_state = IDLE;
        end
      end

      TRANSMIT : begin
        if (data_count == count_to) begin
          next_state = IDLE;
        end
        else begin
          next_state = WAIT;
        end
      end

      WAIT : begin
        if (done == 1) begin
          next_state = TRANSMIT;
        end
        else begin
          next_state = WAIT;
        end
      end

      default : begin
        next_state = IDLE;
      end
    endcase
  end

  //-----------------------------------------------------------------
  // Output Block for ASMD
  //-----------------------------------------------------------------

  always @(
    start        ,
    done         ,
    shift        ,
    load         ,
    clear        ,
    data_count   ,
    current_state 
  )
  begin : output_block
    // Default assignment
    shift  = 1'b0;
    load   = 1'b0;
    clear  = 1'b1;
    finish = 1'b0;

    // Combined actions
    case (current_state)
      IDLE : begin
        if (start) begin
          load       = 1'b1;
          clear      = 1'b0;
          data_count = 0   ;
          count_to   = (parity == 1) ? DATA_WIDTH + 2 : DATA_WIDTH + 1;
        end
        else begin
          shift      = 1'b0;
          load       = 1'b0;
          clear      = 1'b1;
          finish     = 1'b0;
          data_count = 0   ;
        end
      end

      TRANSMIT : begin
        if (data_count == count_to) begin
          shift  = 1'b0;
          load   = 1'b0;
          clear  = 1'b1;
          finish = 1'b1;
        end
        else begin
          load  = 1'b0;
          clear = 1'b0;
        end
      end

      WAIT : begin
        if (done == 1) begin
          shift = 1'b1;
          clear = 1'b0;
        end
        else begin
          shift      = 1'b0          ;
          clear      = 1'b0          ;
          data_count = data_count + 1;
        end
      end
    endcase
  end

endmodule : edabk_transmitter_controller