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
  logic        src_unsigned_cvts, res_unsigned_cvtw;
  logic [31:0] res_bop, res_cmp, res_cvtw;
  class_result_s res_cls;
  logic          invalid_cmp;

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
     .op(3'b101),
     .ack(),
     .res(res_cmp),
     .invalid(invalid_cmp),
     .nrst(nrst)
     );

  ecliptic_converter_to_float CVTS
    (
     .clk(clk),
     .req('b1),
     .src(src1),
     .src_unsigned(src_unsigned_cvts),
     .ack(),
     .res(res_cvts),
     .inexact(),
     .nrst(nrst)
     );

  ecliptic_converter_to_word CVTW
    (
     .clk(clk),
     .req('b1),
     .src(src1),
     .res_unsigned(res_unsigned_cvtw),
     .ack(),
     .res(res_cvtw),
     .invalid(),
     .inexact(),
     .nrst(nrst)
     );

  initial begin
    src_unsigned_cvts = 'b0;
    res_unsigned_cvtw = 'b0;
    ##1;
    src1 = 32'h3f800000;
    src2 = 32'hcf800000;
    ##1;
    src1 = 32'h7f800001;
    src2 = 32'h3f800000;
    ##1;
    src1 = 32'h00000003;
    ##1;
    src_unsigned_cvts = 'b0;
    src1 = 32'hFFFFFFFD;
    ##1;
    src_unsigned_cvts = 'b1;
    src1 = 32'hFFFFFFFD;
    ##1;
    res_unsigned_cvtw = 'b0;
    src1 = 32'h3F800000;
    ##1;
    res_unsigned_cvtw = 'b0;
    src1 = 32'h40400000;
    ##10;
    $finish;
  end

endmodule
