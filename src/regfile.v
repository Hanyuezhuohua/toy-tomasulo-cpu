`include "defines.v"
module REGFILE(
    input wire rst_in,
    input wire clk_in,
    input wire rdy_in,
    input wire transmit_from_issue,
    input wire[`REGFILE_WIDTH] pos_from_issue,
    input wire[`ROB_WIDTH] rob_pos_from_issue,
    input wire write_from_commit,
    input wire[`REGFILE_WIDTH] addr_from_commit,
    input wire[`ROB_WIDTH] rob_pos_from_commit,
    input wire[`DATA_WIDTH] data_from_commit,
    input wire rs1_transmit_from_issue,
    input wire[`REGFILE_WIDTH] rs1_pos_from_issue,
    input wire rs2_transmit_from_issue,
    input wire[`REGFILE_WIDTH] rs2_pos_from_issue,
    output reg[`DATA_WIDTH] rs1_to_issue,
    output reg[`ROB_WIDTH] rs1_rob_pos_to_issue,
    output reg rs1_rdy_to_issue,
    output reg[`DATA_WIDTH] rs2_to_issue,
    output reg[`ROB_WIDTH] rs2_rob_pos_to_issue,
    output reg rs2_rdy_to_issue,
    input wire flush_from_commit
);

reg[`DATA_WIDTH] data[`REGFILE_CAPCITY];
reg[`ROB_WIDTH] ROB[`REGFILE_CAPCITY];
reg[`DATA_WIDTH] busy;

integer i;
always @ (posedge clk_in) begin
    if (rst_in) begin
        busy <= `FREE;
        for(i = 0; i < 32; i = i + 1) begin
           data[i] <= `ZERO_DATA;
        end
    end
    else if (rdy_in) begin
        if (write_from_commit && addr_from_commit != `ZERO_REGFILE) data[addr_from_commit] <= data_from_commit;
        if (transmit_from_issue && pos_from_issue != `ZERO_REGFILE) ROB[pos_from_issue] <= rob_pos_from_issue;
        if (flush_from_commit) busy <= `FREE;
        else if (transmit_from_issue && write_from_commit && addr_from_commit == pos_from_issue && addr_from_commit != `ZERO_REGFILE) busy[pos_from_issue] <= `BUSY;
        else begin
            if (write_from_commit && ROB[addr_from_commit] == rob_pos_from_commit) busy[addr_from_commit] <= `FREE;
            if (transmit_from_issue && pos_from_issue != `ZERO_REGFILE) busy[pos_from_issue] <= `BUSY;
        end
    end
end

always @ (*) begin
    if (rst_in || flush_from_commit || !rs1_transmit_from_issue) begin
        rs1_to_issue = `ZERO_DATA;
        rs1_rdy_to_issue = 1'b0;
        rs1_rob_pos_to_issue = `ZERO_ROB;
    end
    else if (write_from_commit && rs1_pos_from_issue == addr_from_commit && rob_pos_from_commit == ROB[addr_from_commit]) begin
        rs1_to_issue = rs1_pos_from_issue == `ZERO_REGFILE ? `ZERO_DATA : data_from_commit;
        rs1_rdy_to_issue = 1'b1;
        rs1_rob_pos_to_issue = `ZERO_ROB;
    end
    else begin
        rs1_to_issue = data[rs1_pos_from_issue];
        rs1_rdy_to_issue = !busy[rs1_pos_from_issue];
        rs1_rob_pos_to_issue = ROB[rs1_pos_from_issue];
    end
    if (rst_in || flush_from_commit || !rs2_transmit_from_issue) begin
        rs2_to_issue = `ZERO_DATA; 
        rs2_rdy_to_issue = 1'b0;
        rs2_rob_pos_to_issue = `ZERO_ROB;
    end
    else if (write_from_commit && rs2_pos_from_issue == addr_from_commit && rob_pos_from_commit == ROB[addr_from_commit]) begin
        rs2_to_issue = rs2_pos_from_issue == `ZERO_REGFILE ? `ZERO_DATA : data_from_commit; 
        rs2_rdy_to_issue = 1'b1;
        rs2_rob_pos_to_issue = `ZERO_ROB;
    end
    else begin
        rs2_to_issue = data[rs2_pos_from_issue];
        rs2_rdy_to_issue = !busy[rs2_pos_from_issue];
        rs2_rob_pos_to_issue = ROB[rs2_pos_from_issue];
    end
end

endmodule 