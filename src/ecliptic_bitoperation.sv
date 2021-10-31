`default_nettype none
`define OP_SIGN_INJECTION   2'b00
`define OP_SIGN_INJECTION_N 2'b01
`define OP_SIGN_INJECTION_X 2'b10

module ecliptic_bitoperation
  (
   input wire          clk,
   input wire [31:0]   src1,
   input wire [31:0]   src2,
   input wire [1:0]    op,
   input wire          req,
   output logic [31:0] res,
   output logic        ack,
   input wire          nrst
   );

  // bit operation
  // 00: sign injection from src2
  // 01: sign injection (not) from src2
  // 10: sign injection (xor) from src2
  // 11: no operand (src1)
  logic [31:0]         sgnj_res, sgnjn_res, sgnjx_res;
  always_comb begin: bit_operation
    sgnj_res = {src2[$high(src2)], src1[$high(src1)-1:0]};
    sgnjn_res = {~src2[$high(src2)], src1[$high(src1)-1:0]};
    sgnjx_res = {src1[$high(src1)] ^ src2[$high(src2)], src1[$high(src1)-1:0]};
  end

  always_ff @(posedge clk) begin
    if (~nrst) begin
      res <= '0;
      ack <= '0;
    end else begin
      if (req) begin
        case (op)
          `OP_SIGN_INJECTION: res <= sgnj_res;
          `OP_SIGN_INJECTION_N: res <= sgnjn_res;
          `OP_SIGN_INJECTION_X: res <= sgnjx_res;
          default: res <= src1;
        endcase
        ack <= 'b1;
      end else begin
        res <= '0;
        ack <= '0;
      end
    end
  end

endmodule

`default_nettype wire
`undef OP_SIGN_INJECTION
`undef OP_SIGN_INJECTION_N
`undef OP_SIGN_INJECTION_X
