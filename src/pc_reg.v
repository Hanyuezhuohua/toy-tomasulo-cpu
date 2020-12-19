`include "defines.v"
module PC_REG(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    input wire full_from_instqueue,
    output reg write_to_instqueue,
    output reg[`INST_WIDTH] inst_to_instqueue,
    output reg[`ADDR_WIDTH] inst_addr_to_instqueue,
    input wire rdy_from_memctrl,
    input wire[`INST_WIDTH] inst_from_memctrl,
    output reg transmit_to_memctrl,
    output reg[`ADDR_WIDTH] inst_addr_to_memctrl,
    input wire jump_from_commit,
    input wire[`ADDR_WIDTH] jump_addr_from_commit
);

reg[`INST_WIDTH] inst_cache[`INST_CACHE_CAPCITY];
reg[`INST_ADDR_TAG_WIDTH] inst_tag[`INST_CACHE_CAPCITY];
reg[`INST_CACHE_CAPCITY] inst_valid;

reg[`ADDR_WIDTH] addr_now;

wire[`ADDR_WIDTH] addr_next;
wire[`ADDR_WIDTH] jump_addr_next;
wire[`INST_ADDR_INDEX_WIDTH] addr_index;
wire[`INST_ADDR_TAG_WIDTH] addr_tag;
wire[`INST_ADDR_INDEX_WIDTH] addr_next_index;
wire[`INST_ADDR_TAG_WIDTH] addr_next_tag;
wire[`INST_ADDR_INDEX_WIDTH] jump_addr_index;
wire[`INST_ADDR_TAG_WIDTH] jump_addr_tag;
wire[`INST_ADDR_INDEX_WIDTH] jump_addr_next_index;
wire[`INST_ADDR_TAG_WIDTH] jump_addr_next_tag;

assign addr_next = addr_now + `ADDR_DISTANCE;
assign jump_addr_next = jump_addr_from_commit + `ADDR_DISTANCE;
assign addr_index = addr_now[`INST_ADDR_INDEX_RANGE];
assign addr_tag = addr_now[`INST_ADDR_TAG_RANGE];
assign addr_next_index = addr_next[`INST_ADDR_INDEX_RANGE];
assign addr_next_tag = addr_next[`INST_ADDR_TAG_RANGE];
assign jump_addr_index = jump_addr_from_commit[`INST_ADDR_INDEX_RANGE];
assign jump_addr_tag = jump_addr_from_commit[`INST_ADDR_TAG_RANGE];
assign jump_addr_next_index = jump_addr_next[`INST_ADDR_INDEX_RANGE];
assign jump_addr_next_tag = jump_addr_next[`INST_ADDR_TAG_RANGE];

always @ (posedge clk_in) begin
    if (rst_in) begin
        addr_now <= `ZERO_ADDR;
        write_to_instqueue <= `WRITE_DISABLE;
        inst_valid <= `INVALID;
        inst_to_instqueue <= `ZERO_DATA;
        inst_addr_to_instqueue <= `ZERO_ADDR;
    end
    else if(rdy_in) begin
       if(rdy_from_memctrl) begin
          inst_cache[addr_index] <= inst_from_memctrl;
          inst_tag[addr_index] <= addr_tag;
          inst_valid[addr_index] <= `VALID; 
       end
       if(jump_from_commit) begin
          if(inst_valid[jump_addr_index] && inst_tag[jump_addr_index] == jump_addr_tag && !full_from_instqueue) begin
             addr_now <= jump_addr_next;
             write_to_instqueue <= `WRITE_ENABLE;
             inst_addr_to_instqueue <= jump_addr_from_commit;
             inst_to_instqueue <= inst_cache[jump_addr_index];    
          end
          else begin
             addr_now <= jump_addr_from_commit;
             write_to_instqueue <= `WRITE_DISABLE;
          end 
       end
       else begin
          if(inst_valid[addr_index] && inst_tag[addr_index] == addr_tag && !full_from_instqueue) begin
             addr_now <= addr_next; 
             write_to_instqueue <= `WRITE_ENABLE;
             inst_addr_to_instqueue <= addr_now;
             inst_to_instqueue <= inst_cache[addr_index];
          end
          else if(rdy_from_memctrl && !full_from_instqueue) begin
             addr_now <= addr_next;
             write_to_instqueue <= `WRITE_ENABLE;
             inst_addr_to_instqueue <= addr_now;
             inst_to_instqueue <= inst_from_memctrl;
          end
          else write_to_instqueue <= `WRITE_DISABLE;
       end
    end
end

always @(*) begin
    if (rst_in) begin
        transmit_to_memctrl  = `TRANSMIT_DISABLE;
        inst_addr_to_memctrl = `ZERO_ADDR;
    end
    else begin
       if(jump_from_commit) begin
          if(inst_valid[jump_addr_index] && inst_tag[jump_addr_index] == jump_addr_tag && !full_from_instqueue) begin
             if(inst_valid[jump_addr_next_index] && inst_tag[jump_addr_next_index] == jump_addr_next_tag) transmit_to_memctrl = `TRANSMIT_DISABLE;
             else begin
                transmit_to_memctrl = `TRANSMIT_ENABLE;
                inst_addr_to_memctrl = jump_addr_next;
             end
          end
          else begin
             if(inst_valid[jump_addr_index] && inst_tag[jump_addr_index] == jump_addr_tag) transmit_to_memctrl = `TRANSMIT_DISABLE;
             else begin
                transmit_to_memctrl = `TRANSMIT_ENABLE;
                inst_addr_to_memctrl = jump_addr_from_commit;
             end
          end 
       end
       else begin
          if(inst_valid[addr_index] && inst_tag[addr_index] == addr_tag && !full_from_instqueue) begin
             if(inst_valid[addr_next_index] && inst_tag[addr_next_index] == addr_next_tag) transmit_to_memctrl = `TRANSMIT_DISABLE;
             else begin
                transmit_to_memctrl = `TRANSMIT_ENABLE;
                inst_addr_to_memctrl = addr_next;
             end
          end
          else if(rdy_from_memctrl && !full_from_instqueue) begin          
              if(inst_valid[addr_next_index] && inst_tag[addr_next_index] == addr_next_tag) transmit_to_memctrl = `TRANSMIT_DISABLE;
              else begin
                 transmit_to_memctrl = `TRANSMIT_ENABLE;
                 inst_addr_to_memctrl = addr_next;
              end
          end
          else if(!rdy_from_memctrl && !(inst_valid[addr_index] && inst_tag[addr_index] == addr_tag)) begin
             transmit_to_memctrl = `TRANSMIT_ENABLE;
             inst_addr_to_memctrl = addr_now;
          end
          else transmit_to_memctrl = `TRANSMIT_DISABLE;
       end
    end
end

endmodule 