`default_nettype none
`define CANONICAL_NAN 32'h7fc00000

module ecliptic_comparison
  (
   input wire          clk,
   input wire [31:0]   src1,
   input wire [31:0]   src2,
   input wire          req,
   output logic [31:0] minimum,
   output logic [31:0] maximum,
   output logic        lt,
   output logic        le,
   output logic        eq,
   output logic        ack,
   input wire          nrst
   );

  logic                nan_src1, nan_src2;
  logic [31:0]         min_n, max_n;
  logic                lt_n, eq_n, le_n;
  always_comb begin: fp_comparison_min_max
    nan_src1 = (&src1[30:23]) | (|src1[22:0]);
    nan_src2 = (&src2[30:23]) | (|src2[22:0]);
    if (nan_src1 & nan_src2) begin
      min_n = `CANONICAL_NAN;
      max_n = `CANONICAL_NAN;
      lt_n = '0;
    end else if (nan_src1) begin
      min_n = src2;
      max_n = src2;
      lt_n = '0;
    end else if (nan_src2) begin
      min_n = src1;
      max_n = src1;
      lt_n = '0;
    end else begin
      // ordinary case
      case ({src1[$high(src1)], src2[$high(src2)]})
        2'b00, 2'b11: begin
          if (src1[30:23] == src2[30:23]) begin
            if (src1[22:0] < src2[22:0]) begin
              min_n = (src1[31]) ? src2 : src1;
              max_n = (src1[31]) ? src1 : src2;
              lt_n = (src1[31]) ? 'b0 : 'b1;
            end else begin
              min_n = (src1[31]) ? src1 : src2;
              max_n = (src1[31]) ? src2 : src1;
              lt_n = (src1[31]) ? 'b1 : 'b0;
            end
          end else begin
            if (src1[30:23] < src2[30:23]) begin
              min_n = (src1[31]) ? src2 : src1;
              max_n = (src1[31]) ? src1 : src2;
              lt_n = (src1[31]) ? 'b0 : 'b1;
            end else begin
              min_n = (src1[31]) ? src1 : src2;
              max_n = (src1[31]) ? src2 : src1;
              lt_n = (src1[31]) ? 'b1 : 'b0;
            end
          end
        end
        2'b01: begin
          // src1 positive, src2 negative
          min_n = src2;
          max_n = src1;
          lt_n = 'b0;
        end
        2'b10: begin
          // src1 negative, src2 positive
          min_n = src1;
          max_n = src2;
          lt_n = 'b1;
        end
      endcase
    end
    if (nan_src1 | nan_src2) begin
      eq_n = '0;
    end else begin
      if (~(|src1[30:0]) & ~(|src2[30:0])) begin: corner_case_zero
        eq_n = 'b1;
      end else if (~|(src1 ^ src2)) begin
        eq_n = 'b1;
      end else begin
        eq_n = 'b0;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (~nrst) begin
      maximum <= '0;
      minimum <= '0;
      eq <= '0;
      lt <= '0;
      le <= '0;
      ack <= '0;
    end else begin
      if (req) begin
        maximum <= max_n;
        minimum <= min_n;
        eq <= eq_n;
        lt <= lt_n;
        le <= eq_n | lt_n;
        ack <= 'b1;
      end else begin
        maximum <= '0;
        minimum <= '0;
        eq <= '0;
        lt <= '0;
        le <= '0;
        ack <= '0;
      end
    end
  end

endmodule

`default_nettype wire
`undef CANONICAL_NAN
