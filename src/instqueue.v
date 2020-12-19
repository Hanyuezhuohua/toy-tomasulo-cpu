`include "defines.v"
module INSTQUEUE(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    input wire write_from_pc_reg,
    input wire[`INST_WIDTH] inst_from_pc_reg,
    input wire[`ADDR_WIDTH] inst_addr_from_pc_reg,
    output reg full_to_pc_reg,
    input wire transmit_from_issue,
    output reg[`INST_WIDTH] inst_to_issue,
    output reg[`ADDR_WIDTH] inst_addr_to_issue,
    output reg empty_to_issue,
    input wire flush_from_commit
);

reg[`ADDR_WIDTH] inst_addr[`INST_QUEUE_CAPCITY];
reg[`INST_WIDTH] inst[`INST_QUEUE_CAPCITY];
reg[`POINTER_WIDTH] head, tail;

always @ (posedge clk_in) begin
    if (rst_in || flush_from_commit) begin
        head <= `ZERO_POINTER;
        tail <= `ZERO_POINTER;
        full_to_pc_reg <= `NOT_FULL;
        empty_to_issue <= `EMPTY;
        inst_to_issue <= `ZERO_INST;
        inst_addr_to_issue <= `ZERO_ADDR;
    end
    else if (rdy_in) begin
        if(write_from_pc_reg && transmit_from_issue) begin
          inst[tail] <= inst_from_pc_reg;
          inst_addr[tail] <= inst_addr_from_pc_reg;
          head <= head + `POINTER_DISTANCE;
          tail <= tail + `POINTER_DISTANCE;
          full_to_pc_reg <= tail - head >=  `INST_QUEUE_FULL_LENGTH ? `FULL : `NOT_FULL;
          empty_to_issue <= `NOT_EMPTY;
          inst_to_issue <= tail == head + `POINTER_DISTANCE ? inst_from_pc_reg : inst[head + 1];
          inst_addr_to_issue <= tail == head + `POINTER_DISTANCE ? inst_addr_from_pc_reg : inst_addr[head + 1];
        end
        else if(write_from_pc_reg && !transmit_from_issue) begin
           inst[tail] <= inst_from_pc_reg;
           inst_addr[tail] <= inst_addr_from_pc_reg;
           tail <= tail + `POINTER_DISTANCE;
           full_to_pc_reg <= tail - head >=  `INST_QUEUE_FULL_LENGTH ? `FULL : `NOT_FULL;
           empty_to_issue <= `NOT_EMPTY; 
           inst_to_issue <= tail == head ? inst_from_pc_reg : inst[head];
           inst_addr_to_issue <= tail == head ? inst_addr_from_pc_reg : inst_addr[head];
        end
        else if(!write_from_pc_reg && transmit_from_issue) begin
           head <= head + `POINTER_DISTANCE;
           full_to_pc_reg <= tail - head - transmit_from_issue >=  `INST_QUEUE_FULL_LENGTH ? `FULL : `NOT_FULL;
           empty_to_issue <= tail == head + transmit_from_issue ? `EMPTY : `NOT_EMPTY;
           inst_to_issue <= inst[head + 1];
           inst_addr_to_issue <= inst_addr[head + 1];
        end
        else if(!write_from_pc_reg && !transmit_from_issue) begin
           full_to_pc_reg <= tail - head >=  `INST_QUEUE_FULL_LENGTH ? `FULL : `NOT_FULL;
           empty_to_issue <= tail == head ? `EMPTY : `NOT_EMPTY;
        end
    end
end

endmodule 