
module dram
 #(parameter   data_width_p       = 64
   , parameter addr_width_p       = 32
   , parameter mem_cap_in_bytes_p = 2**28
   , parameter mem_load_p         = 0
   , parameter mem_file_p         = "inv"

   , localparam num_data_bytes_lp   = data_width_p / 8 
   , localparam mem_cap_in_words_lp = mem_cap_in_bytes_p / num_data_bytes_lp
   , localparam byte_els_lp         = $clog2(mem_cap_in_bytes_p)
   )
  (input                            clk_i
   , input                          reset_i

   , input                          v_i
   , input                          w_i

   , input [addr_width_p-1:0]       addr_i
   , input [data_width_p-1:0]       data_i
   , input [num_data_bytes_lp-1:0]  write_mask_i

   , output [data_width_p-1:0]      data_o
   );

wire unused = &{reset_i};

logic [7:0] mem [0:mem_cap_in_bytes_p-1];

logic [data_width_p-1:0] data_li, data_lo;
logic [addr_width_p-1:0] addr_r;

always_comb
  for (integer i = 0; i < num_data_bytes_lp; i++)
    data_lo[i*8+:8] = mem[addr_r+byte_els_lp'(i)];

assign data_li = data_i;

initial
  begin
    if (mem_load_p)
      begin
        for (integer i = 0; i < mem_cap_in_bytes_p; i++)
          mem[i] = '0;
        $readmemh(mem_file_p, mem);     
      end
  end

always @(posedge clk_i)
  begin
    if (v_i & w_i)
      // byte-maskable writes
      begin
        for (integer i = 0; i < num_data_bytes_lp; i++)
          begin
            if (write_mask_i[i])
              mem[addr_i+i] <= data_li[i*8+:8];
          end
      end
    if (v_i & ~w_i)
      addr_r <= addr_i;
  end

assign data_o = data_lo;

endmodule
