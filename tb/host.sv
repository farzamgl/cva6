
module host
 #(parameter addr_width_p = 32
   , parameter data_width_p = 64
   , localparam mask_width_lp = data_width_p/8
  )
  (input clk_i
   , input reset_i

   , input req_i
   , input we_i
   , input [addr_width_p-1:0] addr_i
   , input [data_width_p-1:0] data_i
   , input [mask_width_lp-1:0] be_i

   , output [data_width_p-1:0] data_o
  );

  assign data_o = '0;

  logic putchar_v, finish_v;
  assign putchar_v = req_i & we_i & ((addr_i & 16'hFFFF) == 16'h1000);
  assign finish_v  = req_i & we_i & ((addr_i & 16'hFFFF) == 16'h2000);

  always_ff @(negedge clk_i) begin
    if(putchar_v) begin
      $write("%c", data_i[0+:8]);
      $fflush(32'h8000_0001);
    end

    if(finish_v) begin
      $display("Finish called with code: %d\n", data_i);
      $finish();
    end
  end

endmodule
