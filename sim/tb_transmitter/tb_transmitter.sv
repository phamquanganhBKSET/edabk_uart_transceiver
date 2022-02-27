`include "../../inc/edabk_uart_transceiver_define.svh"

module tb_transmitter;

  parameter DATA_WIDTH = `CFG_DATA_WIDTH;

  // Signals and variables of transmitter
  reg                  clk     ;
  reg                  reset_n ;
  reg [2:0]            baudrate;
  wire                 bclk    ;
  reg                  start   ;
  reg                  parity  ;
  reg [DATA_WIDTH-1:0] tx_in   ;
  wire                 tx_out  ;
  wire                 finish  ;

  // Signals and variables of fifo
  reg                  write     ;
  reg                  read      ;
  reg                  flush     ;
  reg [DATA_WIDTH-1:0] write_data;
  reg [DATA_WIDTH-1:0] read_data ;
  wire                 empty     ;
  wire                 full      ;

  baud_generator baud_generator (
    .clk     (clk     ),
    .reset_n (reset_n ),
    .baudrate(baudrate),
    .bclk    (bclk    ) 
  );

  edabk_io_fifo uart_io_fifo (
    .clk       (bclk      ),
    .reset_n   (reset_n   ),
    .write     (write     ),
    .read      (finish    ),
    .flush     (flush     ),
    .write_data(write_data),
    .read_data (tx_in     ),
    .empty     (empty     ),
    .full      (full      ) 
  );

  edabk_transmitter uart_transmitter (
    .bclk   (bclk   ),
    .reset_n(reset_n),
    .start  (start  ),
    .parity (parity ),
    .tx_in  (tx_in  ),
    .tx_out (tx_out ),
    .finish (finish ) 
  );

  initial begin
    clk      = 0;
    reset_n  = 0;
    start    = 0;
    parity   = 1;
    tx_in    = 0;
    baudrate = 3'b011;
  end

  always #5 begin
    clk = ~clk;
  end

  initial begin
    #1;
    reset_n = 0;
    #8;
    reset_n = 1;
    for (int i = 0; i < 10; i++) begin
      @(negedge bclk) begin
        write <= 1;
        write_data <= 8'b10101010;
      end
      @(negedge bclk) begin
        write <= 1;
        write_data <= 8'b10101011;
      end
    end
    @(negedge bclk) begin
      start <= 1;
    end
    
    /*
    @(negedge bclk) begin
      start <= 0;
    end
    for (int i = 0; i < 100; i++) begin
      @(negedge finish) begin
        @(negedge bclk);
        @(negedge bclk);
          start <= 1;
      end
      @(negedge bclk);
      start <= 0;
    end
    */

    #100000000;
    $stop;
  end

endmodule : tb_transmitter