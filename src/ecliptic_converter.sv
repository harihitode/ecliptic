`default_nettype none

`define MAX_SIGNED_INTEGER 32'h7FFF_FFFF;
`define MIN_SIGNED_INTEGER 32'hFFFF_FFFF;
`define MAX_UNSIGNED_INTEGER 32'hFFFF_FFFF;
`define ZERO 32'h0000_0000;

module ecliptic_converter_from_int
  (
   input wire          clk,
   input wire          req,
   input wire [31:0]   src,
   input wire [1:0]    rm,
   input wire          src_unsigned,
   output logic        ack,
   output logic [31:0] res,
   output logic        inexact,
   input wire          nrst
   );

  // when src_unsigned find first one from $high(src)
  // when not src_unsigned find first one from $high(src)-1
  logic                signflag;
  logic [7:0]          exponent;
  logic [22:0]         mantissa;
  logic [31:0]         src_abs;
  always_comb begin
    signflag = (src_unsigned) ? 'b0 : src[$high(src)];
    if (signflag) begin
      src_abs = -src;
    end else begin
      src_abs = src;
    end
    exponent = '0;
    for (int i = 30; i >= 0; i--) begin
      if (src_abs[i]) begin
        exponent = i;
        break;
      end
    end
    if (src_unsigned & src_abs[$high(src_abs)]) begin
      exponent = 31;
    end
    if (exponent > 'd23) begin
      mantissa = src_abs >> (exponent - 'd23);
    end else begin
      mantissa = src_abs << ('d23 - exponent);
    end
    exponent = exponent + 'd127;
  end
  always_ff @(posedge clk) begin
    if (~nrst) begin
      ack <= '0;
      res <= '0;
      inexact <= '0;
    end else begin
      if (req) begin
        ack <= 'b1;
        res <= {signflag, exponent, mantissa};
      end else begin
        ack <= '0;
        res <= '0;
        inexact <= '0;
      end
    end
  end

endmodule

`default_nettype wire
