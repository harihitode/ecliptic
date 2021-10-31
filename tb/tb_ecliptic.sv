`timescale 1 ns / 1 ps

module tb_ecliptic;
  logic clk = '0;
  logic nrst = 'b1;
  initial forever #5 clk = ~clk;

  default clocking cb @(posedge clk);
  endclocking

  typedef struct packed {
    logic        qNaN;
    logic        sNaN;
    logic        pInf;
    logic        pNormal;
    logic        pSubnormal;
    logic        pZero;
    logic        nZero;
    logic        nSubnormal;
    logic        nNormal;
    logic        nInf;
  } class_result_s;

  logic [31:0] src1, src2;
  logic [31:0] res_bop, res_cmp_min, res_cmp_max;
  class_result_s res_cls;
  logic          res_cmp_le, res_cmp_lt, res_cmp_eq;

  ecliptic_bitoperation BOP
    (
     .clk(clk),
     .req('b1),
     .src1(src1),
     .src2(src2),
     .op(2'b00),
     .ack(),
     .res(res_bop),
     .nrst(nrst)
     );

  ecliptic_classification CLS
    (
     .clk(clk),
     .req('b1),
     .src(src1),
     .ack(),
     .res(res_cls),
     .nrst(nrst)
     );

  ecliptic_comparison CMP
    (
     .clk(clk),
     .req('b1),
     .src1(src1),
     .src2(src2),
     .ack(),
     .minimum(res_cmp_min),
     .maximum(res_cmp_max),
     .lt(res_cmp_lt),
     .eq(res_cmp_eq),
     .le(res_cmp_le),
     .nrst(nrst)
     );

  initial begin
    ##1;
    src1 = 32'h3f800000;
    src2 = 32'hcf800000;
    ##1;
    src1 = 32'h7fc00000;
    src2 = 32'h3f800000;
    ##10;
    $finish;
  end

endmodule
