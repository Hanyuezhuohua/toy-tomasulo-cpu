`include "defines.v"
module ROB(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    output reg full_to_issue,
    input wire transmit_from_issue,
    input wire rdy_from_issue,
    input wire[`REGFILE_WIDTH] regfile_pos_from_issue,
    input wire[`TYPE_WIDTH] type_from_issue,
    output reg[`ROB_WIDTH] allocated_pos_to_issue,
    input wire rdy_from_commit,
    output reg transmit_to_commit,
    output reg[`ROB_WIDTH] rob_pos_to_commit,
    output reg[`REGFILE_WIDTH] regfile_pos_to_commit,
    output reg[`DATA_WIDTH] data_to_commit,
    output reg[`ADDR_WIDTH] jump_addr_to_commit,
    output reg[`TYPE_WIDTH] type_to_commit,
    output reg jump_to_commit,
    input wire transmit_cdb,
    input wire[`ROB_WIDTH] rob_pos_cdb,
    input wire[`DATA_WIDTH] data_cdb,
    input wire[`ADDR_WIDTH] jump_addr_cdb,
    input wire jump_cdb,
    input wire transmit_cdb_sl,
    input wire[`ROB_WIDTH] rob_pos_cdb_sl,
    input wire[`DATA_WIDTH] data_cdb_sl,
    input wire rs1_transmit_from_issue,
    input wire rs2_transmit_from_issue,
    input wire[`ROB_WIDTH] rs1_rob_pos_from_issue,
    input wire[`ROB_WIDTH] rs2_rob_pos_from_issue,
    output reg rs1_rdy_to_issue,
    output reg rs2_rdy_to_issue,
    output reg[`DATA_WIDTH] rs1_to_issue,
    output reg[`DATA_WIDTH] rs2_to_issue,
    input wire flush_from_commit,
    output reg transmit_to_slbuffer
);

reg[`DATA_WIDTH] write_data[`ROB_CAPCITY];
reg[`ADDR_WIDTH] jump_addr[`ROB_CAPCITY];
reg jump[`ROB_CAPCITY];
reg[`REGFILE_WIDTH] write_addr[`ROB_CAPCITY];
reg[`TYPE_WIDTH] type[`ROB_CAPCITY];
reg ready[`ROB_CAPCITY];
reg[`LONG_POINTER_WIDTH] head, tail, head_ensure;

always @ (posedge clk_in) begin
    if (rst_in || flush_from_commit) begin
        head <= `ZERO_POINTER;
        tail <= `ZERO_POINTER;
        head_ensure <= `ZERO_POINTER;
        full_to_issue <= `NOT_FULL;
        transmit_to_commit <= `TRANSMIT_DISABLE;
        allocated_pos_to_issue <= `ZERO_ROB;
        transmit_to_slbuffer <= `TRANSMIT_DISABLE;
    end
    else if (rdy_in) begin
        if (transmit_from_issue) begin
            write_addr[tail[`MOD_WIDTH]] <= regfile_pos_from_issue;
            ready[tail[`MOD_WIDTH]] <= rdy_from_issue;
            type[tail[`MOD_WIDTH]] <= type_from_issue;
        end
        if (transmit_cdb) begin
            ready[rob_pos_cdb] <= `READY;
            write_data[rob_pos_cdb] <= data_cdb;
            jump[rob_pos_cdb] <= jump_cdb;
            jump_addr[rob_pos_cdb] <= jump_addr_cdb;
        end
        if (transmit_cdb_sl) begin
            ready[rob_pos_cdb_sl] <= `READY;
            write_data[rob_pos_cdb_sl] <= data_cdb_sl;
        end
        allocated_pos_to_issue <= tail[`MOD_WIDTH] + transmit_from_issue;
        head <= head + rdy_from_commit;
        tail <= tail + transmit_from_issue;
        full_to_issue <= tail + transmit_from_issue - head - rdy_from_commit >= `ROB_FULL_LENGTH;
        if (head_ensure < tail) begin
            if (head + rdy_from_commit > head_ensure) head_ensure <= head + rdy_from_commit;
            else head_ensure <= head_ensure + ((type[head_ensure[`MOD_WIDTH]] != `JUMP_TYPE) ? `TRANSMIT_ENABLE : `TRANSMIT_DISABLE);
            transmit_to_slbuffer <= type[head_ensure[`MOD_WIDTH]] == `SL_TYPE ? `TRANSMIT_ENABLE : `TRANSMIT_DISABLE;
        end
        else transmit_to_slbuffer <= `TRANSMIT_DISABLE;
        if ((tail[`MOD_WIDTH] != head[`MOD_WIDTH] + rdy_from_commit) && ready[head[`MOD_WIDTH] + rdy_from_commit]) begin
            transmit_to_commit <= `TRANSMIT_ENABLE;
            data_to_commit <= write_data[head[`MOD_WIDTH] + rdy_from_commit];
            rob_pos_to_commit <= head[`MOD_WIDTH] + rdy_from_commit;
            regfile_pos_to_commit <= write_addr[head[`MOD_WIDTH] + rdy_from_commit];
            jump_addr_to_commit <= jump_addr[head[`MOD_WIDTH] + rdy_from_commit];
            type_to_commit <= type[head[`MOD_WIDTH] + rdy_from_commit];
            jump_to_commit <= jump[head[`MOD_WIDTH] + rdy_from_commit];
        end
        else transmit_to_commit <= `TRANSMIT_DISABLE;
    end 
end

always @ (*) begin
    if (rst_in || flush_from_commit || !rs1_transmit_from_issue) begin
        rs1_rdy_to_issue = `UNAVAILABLE;
        rs1_to_issue = `ZERO_DATA; 
    end
    else if (transmit_cdb && rs1_rob_pos_from_issue == rob_pos_cdb) begin
        rs1_rdy_to_issue = `READY;
        rs1_to_issue = data_cdb;
    end
    else if (transmit_cdb_sl && rs1_rob_pos_from_issue == rob_pos_cdb_sl) begin
        rs1_rdy_to_issue = `READY;
        rs1_to_issue = data_cdb_sl;
    end
    else if (ready[rs1_rob_pos_from_issue]) begin
        rs1_rdy_to_issue = `READY;
        rs1_to_issue = write_data[rs1_rob_pos_from_issue];
    end
    else begin
        rs1_rdy_to_issue = `UNAVAILABLE;
        rs1_to_issue = `ZERO_DATA;
    end
    if (rst_in || flush_from_commit || !rs2_transmit_from_issue) begin
        rs2_rdy_to_issue = `UNAVAILABLE;
        rs2_to_issue = `ZERO_DATA; 
    end
    else if (transmit_cdb && rs2_rob_pos_from_issue == rob_pos_cdb) begin
        rs2_rdy_to_issue = `READY;
        rs2_to_issue = data_cdb; 
    end
    else if (transmit_cdb_sl && rs2_rob_pos_from_issue == rob_pos_cdb_sl) begin
        rs2_rdy_to_issue = `READY;
        rs2_to_issue = data_cdb_sl; 
    end
    else if (ready[rs2_rob_pos_from_issue]) begin
        rs2_rdy_to_issue = `READY;
        rs2_to_issue = write_data[rs2_rob_pos_from_issue];
    end
    else begin
        rs2_rdy_to_issue = `UNAVAILABLE;
        rs2_to_issue = `ZERO_DATA;
    end
end
endmodule 