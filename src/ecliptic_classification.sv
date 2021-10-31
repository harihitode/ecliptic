`default_nettype none

module ecliptic_classification
  (
   input wire         clk,
   input wire [31:0]  src,
   input wire         req,
   output logic [9:0] res,
   output logic       ack,
   input wire         nrst
   );

  logic               infinite, zero, subnormal, normal;
  logic               ninf, nnml, nsnml, nzero;
  logic               pzero, psnml, pnml, pinf;
  logic               snan, qnan;

  always_comb begin: fp_classification
    qnan = (&src[30:23]) & src[22];
    snan = (&src[30:23]) & ~src[22] & (|src[21:0]);
    infinite = (&src[30:23]) & ~(|src[22:0]);
    zero = ~(|src[30:0]);
    subnormal = ~(|src[30:23]) & (|src[22:0]);
    normal = (~zero & ~subnormal & ~infinite & ~qnan & ~snan);
    ninf  =  src[31] & infinite;
    pinf  = ~src[31] & infinite;
    nzero =  src[31] & zero;
    pzero = ~src[31] & zero;
    nsnml =  src[31] & subnormal;
    psnml = ~src[31] & subnormal;
    nnml  =  src[31] & normal;
    pnml  = ~src[31] & normal;
  end

  always_ff @(posedge clk) begin
    if (~nrst) begin
      ack <= '0;
      res <= '0;
    end else begin
      if (req) begin
        ack <= '0;
        res <= {qnan, snan, pinf, pnml, psnml, pzero, nzero, nsnml, nnml, ninf};
      end else begin
        ack <= 'b1;
        res <= '0;
      end
    end
  end

endmodule

`default_nettype wire
