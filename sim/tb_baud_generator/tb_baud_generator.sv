`timescale 1ns/1ps

module tb_baud_generator;

  reg       clk     ;
  reg       reset_n ;
  reg [2:0] baudrate;
  wire      bclk    ;

  baud_generator bg(
    .clk     (clk     ),
    .reset_n (reset_n ),
    .baudrate(baudrate),
    .bclk    (bclk    ) 
  );

  initial begin
    clk = 0;
    reset_n = 0;
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
    #10000000;
    $stop;
  end

endmodule : tb_baud_generator