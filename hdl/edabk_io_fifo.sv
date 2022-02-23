//------------------------------------------------------------------------------------------------------------------
//    Project: edabk_uart_transceiver
//    Module: edabk_io_fifo
//    Author: anhpq0
//    Date: 28/01/2022
//    Modify: 
//-------------------------------------------------------------------------------------------------------------------

`include "../inc/edabk_uart_transceiver_define.svh"

module edabk_io_fifo #(
  parameter DATA_WIDTH    = `CFG_DATA_WIDTH                            , // Number of bits which is transmitted
  parameter ADDRESS_WIDTH = 8                                            // Number of address bits
)
(
  input                   clk       ,  // Clock signal
  input                   reset_n   ,  // Asynchronous reset active low
  input                   write     ,  // Command write
  input                   read      ,  // Command read
  input                   flush     ,  // Flush FIFO
  input  [DATA_WIDTH-1:0] write_data,  // Writed data
  output [DATA_WIDTH-1:0] read_data ,  // Read data
  output reg              empty     ,  // Status signal: empty
  output reg              full         // Status signal: full
);

  reg  [DATA_WIDTH-1:0]    fifo         [0:2**ADDRESS_WIDTH-1]; // Data in FIFO
  reg  [ADDRESS_WIDTH-1:0] write_ptr                          ; // Write pointer
  reg  [ADDRESS_WIDTH-1:0] read_ptr                           ; // Read pointer
  wire                     write_enable                       ; // Write enable
  wire                     read_enable                        ; // Read enable

  //-----------------------------------------------------------------
  // Write enable and read enable
  //-----------------------------------------------------------------

  assign write_enable = (write & (~full)); // write == 1 and FIFO is not full
  assign read_enable  = (read & (~empty)); // read == 1 and FIFO is not empty

  //-----------------------------------------------------------------
  // Full and empty
  //-----------------------------------------------------------------

  always @(posedge clk, negedge reset_n) begin : full_assignment
    if(~reset_n) begin
      full <= 0;
    end else begin
      if (flush) begin
        full <= 0;
      end
      else if ((((read_ptr == write_ptr + 1) || ((read_ptr == 0) && (write_ptr == 2**ADDRESS_WIDTH - 1))) && write) || 
                (full & (~read))) begin
        full <= 1;
      end
      else begin
        full <= 0;
      end
    end
  end

  always @(posedge clk, negedge reset_n) begin : empty_assignment
    if(~reset_n) begin
      empty <= 1;
    end else begin
      if (flush) begin
        empty <= 1;
      end
      else if ((((write_ptr == read_ptr + 1) || ((write_ptr == 0) && (read_ptr == 2**ADDRESS_WIDTH - 1))) && read) || 
                (empty & (~write))) begin
        empty <= 1;
      end
      else begin
        empty <= 0;
      end
    end
  end

  //-----------------------------------------------------------------
  // Write pointer and read pointer
  //-----------------------------------------------------------------

  always @(posedge clk, negedge reset_n) begin : write_pointer
    if(~reset_n) begin
      write_ptr <= {ADDRESS_WIDTH{1'b1}};
    end else begin
      if (write_enable) begin
        write_ptr <= write_ptr + 1;
      end
      else begin
        write_ptr <= write_ptr;
      end
    end
  end

  always @(posedge clk, negedge reset_n) begin : read_pointer
    if(~reset_n) begin
      read_ptr <= {ADDRESS_WIDTH{1'b1}};
    end else begin
      if (read_enable) begin
        read_ptr <= read_ptr + 1;
      end
      else begin
        read_ptr <= read_ptr;
      end
    end
  end

  //-----------------------------------------------------------------
  // Update data in FIFO
  //-----------------------------------------------------------------

  always @(posedge clk, negedge reset_n) begin : update_data_fifo
    if(~reset_n) begin
      for (int i = 0; i < 2**ADDRESS_WIDTH; i++) begin
        fifo[i] <= 0;
      end
    end else begin
      if (flush) begin
        for (int i = 0; i < 2**ADDRESS_WIDTH; i++) begin
          fifo[i] <= 0;
        end
      end
      else if (write_enable) begin
        fifo[write_ptr] <= write_data;
      end
      else if (read_enable) begin
        fifo[read_ptr] <= 0;
      end
      else begin
        for (int i = 0; i < 2**ADDRESS_WIDTH; i++) begin
          fifo[i] <= fifo[i];
        end
      end
    end
  end

  //-----------------------------------------------------------------
  // Read data
  //-----------------------------------------------------------------

  assign read_data = fifo[read_ptr];


endmodule : edabk_io_fifo