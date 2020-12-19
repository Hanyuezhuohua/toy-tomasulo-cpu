`include "defines.v"
module COMMIT(
    input wire rst_in,
    input wire clk_in,

    input wire transmit_from_rob,
    input wire[`REGFILE_WIDTH] regfile_pos_from_rob,
    input wire[`ROB_WIDTH] rob_pos_from_rob,
    input wire[`DATA_WIDTH] data_from_rob,
    input wire[`ADDR_WIDTH] jump_addr_from_rob,
    input wire[`TYPE_WIDTH] type_from_rob,
    input wire jump_from_rob,

    output reg write_to_regfile,
    output reg[`REGFILE_WIDTH] addr_to_regfile,
    output reg[`ROB_WIDTH] rob_pos_to_regfile,
    output reg[`DATA_WIDTH] data_to_regfile,
    
    output reg transmit_to_rob,

    output reg flush_from_commit,
    output reg jump_from_commit,
    output reg[`ADDR_WIDTH] jump_addr_from_commit
);

always @ (*) begin
    write_to_regfile = (rst_in || !transmit_from_rob || regfile_pos_from_rob == `ZERO_REGFILE) ? `WRITE_DISABLE : `WRITE_ENABLE;
    addr_to_regfile = (rst_in || !transmit_from_rob) ? `ZERO_REGFILE : regfile_pos_from_rob;
    rob_pos_to_regfile = (rst_in || !transmit_from_rob || regfile_pos_from_rob == `ZERO_REGFILE) ? `ZERO_ROB : rob_pos_from_rob;
    data_to_regfile = (rst_in || !transmit_from_rob || regfile_pos_from_rob == `ZERO_REGFILE) ? `ZERO_DATA : data_from_rob;
    transmit_to_rob = (rst_in || !transmit_from_rob) ? `UNAVAILABLE : `READY;
    flush_from_commit = (!rst_in && transmit_from_rob && jump_from_rob && type_from_rob == `JUMP_TYPE) ? `FLUSH_ENABLE : `FLUSH_DISABLE;
    jump_from_commit = flush_from_commit;
    jump_addr_from_commit = (!rst_in && transmit_from_rob && jump_from_rob && type_from_rob == `JUMP_TYPE) ? jump_addr_from_rob : `ZERO_ADDR;
end


endmodule 