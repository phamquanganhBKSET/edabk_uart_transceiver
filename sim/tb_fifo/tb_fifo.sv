`include "../../inc/edabk_uart_transceiver_define.svh"

module tb_fifo;

  parameter DATA_WIDTH = `CFG_DATA_WIDTH;

  reg                   clk       ;
  reg                   reset_n   ;
  reg                   write     ;
  reg                   read      ;
  reg                   flush     ;
  reg  [DATA_WIDTH-1:0] write_data;
  wire [DATA_WIDTH-1:0] read_data ;
  wire                  empty     ;
  wire                  full      ;

  edabk_io_fifo #(.ADDRESS_WIDTH(2)) io_fifo(
    .clk       (clk       ),
    .reset_n   (reset_n   ),
    .write     (write     ),
    .read      (read      ),
    .flush     (flush     ),
    .write_data(write_data),
    .read_data (read_data ),
    .empty     (empty     ),
    .full      (full      ) 
  );

  initial begin
    clk = 0;
    reset_n = 0;
    write = 0;
    read = 0;
    flush = 0;
    write_data = 0;
  end

  always #5 begin
    clk = ~clk;
  end

  initial begin
    #1;
    reset_n = 0;
    #8;
    reset_n = 1;
    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101010;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101011;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101101;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101110;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101111;
    end

    @(negedge clk) begin
      write <= 0;
    end

    @(negedge clk) begin
      read <= 1;
    end

    @(negedge clk) begin
      read <= 1;
    end

    @(negedge clk) begin
      read <= 1;
    end

    @(negedge clk) begin
      read <= 1;
    end

    @(negedge clk) begin
      read <= 0;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101111;
    end

    @(negedge clk) begin
      write <= 1;
      write_data <= 8'b10101111;
    end

    @(negedge clk) begin
      write <= 0;
      read <= 1;
    end

    @(negedge clk) begin
      write <= 0;
      read <= 1;
    end

    @(negedge clk) begin
      write <= 1;
      read <= 0;
    end

    #100;
    $stop;
  end

endmodule : tb_fifo