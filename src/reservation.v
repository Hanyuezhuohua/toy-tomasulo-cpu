`include "defines.v"
module RESERVATION(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    
    input wire write_from_issue,
    input wire[`DATA_WIDTH] rs1_from_issue,
    input wire[`DATA_WIDTH] rs2_from_issue,
    input wire rs1_rdy_from_issue,
    input wire rs2_rdy_from_issue,
    input wire[`ROB_WIDTH] rs1_rob_pos_from_issue,
    input wire[`ROB_WIDTH] rs2_rob_pos_from_issue,
    input wire[`ADDR_WIDTH] inst_addr_from_issue,
    input wire[`DATA_WIDTH] imm_from_issue,
    input wire[`OPCODE_WIDTH] opcode_from_issue,
    input wire[`FUNCT7_WIDTH] funct7_from_issue,
    input wire[`FUNCT3_WIDTH] funct3_from_issue,
    input wire[`ROB_WIDTH] rob_pos_from_issue,
    output full_to_issue,
    
    output reg transmit_to_ex,
    output reg[`DATA_WIDTH] rs1_to_ex,
    output reg[`DATA_WIDTH] rs2_to_ex,
    output reg[`DATA_WIDTH] imm_to_ex,
    output reg[`ADDR_WIDTH] inst_addr_to_ex,
    output reg[`OPCODE_WIDTH] opcode_to_ex,
    output reg[`FUNCT7_WIDTH] funct7_to_ex,
    output reg[`FUNCT3_WIDTH] funct3_to_ex,
    output reg[`ROB_WIDTH] rob_pos_to_ex,
        
    input wire transmit_cdb,
    input wire[`ROB_WIDTH] rob_pos_cdb,
    input wire[`DATA_WIDTH] data_cdb,

    input wire transmit_cdb_sl,
    input wire[`ROB_WIDTH] rob_pos_cdb_sl,
    input wire[`DATA_WIDTH] data_cdb_sl,

    input wire flush_from_commit
);

reg[`RESERVE_STATION_WIDTH] RS_in_use;
reg[`OPCODE_WIDTH] RS_opcode[`RESERVE_STATION_WIDTH];
reg[`DATA_WIDTH] RS_imm[`RESERVE_STATION_WIDTH];
reg[`FUNCT7_WIDTH] RS_funct7[`RESERVE_STATION_WIDTH];
reg[`FUNCT3_WIDTH] RS_funct3[`RESERVE_STATION_WIDTH];
reg RS_rs1_ready[`RESERVE_STATION_WIDTH];
reg RS_rs2_ready[`RESERVE_STATION_WIDTH];
reg[`DATA_WIDTH] RS_rs1_data[`RESERVE_STATION_WIDTH];
reg[`DATA_WIDTH] RS_rs2_data[`RESERVE_STATION_WIDTH];
reg[`ROB_WIDTH] RS_rs1_ROB[`RESERVE_STATION_WIDTH];
reg[`ROB_WIDTH] RS_rs2_ROB[`RESERVE_STATION_WIDTH];
reg[`ROB_WIDTH] RS_rd_ROB[`RESERVE_STATION_WIDTH];
reg[`ADDR_WIDTH] RS_pc[`RESERVE_STATION_WIDTH];

integer i;
assign full_to_issue = RS_in_use ? `BUSY : `FREE;

always @ (posedge clk_in) begin
    if (rst_in || flush_from_commit) RS_in_use <= `FREE;
    else if (rdy_in) begin
        for(i = 0; i < 16; i = i + 1) begin
           if(RS_in_use[i] && !RS_rs1_ready[i]) begin
              if(transmit_cdb && RS_rs1_ROB[i] == rob_pos_cdb) begin
                 RS_rs1_data[i] <= data_cdb;
                 RS_rs1_ready[i] <= `READY;
              end
              else if(transmit_cdb_sl && RS_rs1_ROB[i] == rob_pos_cdb_sl) begin
                 RS_rs1_data[i] <= data_cdb_sl;
                 RS_rs1_ready[i] <= `READY;
              end
           end
           if(RS_in_use[i] && !RS_rs2_ready[i]) begin
              if(transmit_cdb && RS_rs2_ROB[i] == rob_pos_cdb) begin
                 RS_rs2_data[i] <= data_cdb;
                 RS_rs2_ready[i] <= `READY;
              end
              else if(transmit_cdb_sl && RS_rs2_ROB[i] == rob_pos_cdb_sl) begin
                 RS_rs2_data[i] <= data_cdb_sl;
                 RS_rs2_ready[i] <= `READY;
              end
           end
        end
        if(write_from_issue && !((rs1_rdy_from_issue || transmit_cdb && rs1_rob_pos_from_issue == rob_pos_cdb  || transmit_cdb_sl && rs1_rob_pos_from_issue == rob_pos_cdb_sl) && (rs2_rdy_from_issue || transmit_cdb && rs2_rob_pos_from_issue == rob_pos_cdb || transmit_cdb_sl && rs2_rob_pos_from_issue == rob_pos_cdb_sl))) begin
           if(!RS_in_use[0]) begin
              RS_in_use[0] <= `BUSY;
              RS_opcode[0] <= opcode_from_issue;
              RS_imm[0] <= imm_from_issue;
              RS_funct7[0] <= funct7_from_issue;
              RS_funct3[0] <= funct3_from_issue;
              RS_rs1_ready[0] <= rs1_rdy_from_issue;
              RS_rs2_ready[0] <= rs2_rdy_from_issue;
              RS_rs1_data[0] <= rs1_from_issue;
              RS_rs2_data[0] <= rs2_from_issue;
              RS_rs1_ROB[0] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[0] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[0] <= rob_pos_from_issue;
              RS_pc[0] <= inst_addr_from_issue;
           end
           else if(!RS_in_use[1]) begin
              RS_in_use[1] <= `BUSY;
              RS_opcode[1] <= opcode_from_issue;
              RS_imm[1] <= imm_from_issue;
              RS_funct7[1] <= funct7_from_issue;
              RS_funct3[1] <= funct3_from_issue;
              RS_rs1_ready[1] <= rs1_rdy_from_issue;
              RS_rs2_ready[1] <= rs2_rdy_from_issue;
              RS_rs1_data[1] <= rs1_from_issue;
              RS_rs2_data[1] <= rs2_from_issue;
              RS_rs1_ROB[1] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[1] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[1] <= rob_pos_from_issue;
              RS_pc[1] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[2]) begin
              RS_in_use[2] <= `BUSY;
              RS_opcode[2] <= opcode_from_issue;
              RS_imm[2] <= imm_from_issue;
              RS_funct7[2] <= funct7_from_issue;
              RS_funct3[2] <= funct3_from_issue;
              RS_rs1_ready[2] <= rs1_rdy_from_issue;
              RS_rs2_ready[2] <= rs2_rdy_from_issue;
              RS_rs1_data[2] <= rs1_from_issue;
              RS_rs2_data[2] <= rs2_from_issue;
              RS_rs1_ROB[2] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[2] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[2] <= rob_pos_from_issue;
              RS_pc[2] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[3]) begin
              RS_in_use[3] <= `BUSY;
              RS_opcode[3] <= opcode_from_issue;
              RS_imm[3] <= imm_from_issue;
              RS_funct7[3] <= funct7_from_issue;
              RS_funct3[3] <= funct3_from_issue;
              RS_rs1_ready[3] <= rs1_rdy_from_issue;
              RS_rs2_ready[3] <= rs2_rdy_from_issue;
              RS_rs1_data[3] <= rs1_from_issue;
              RS_rs2_data[3] <= rs2_from_issue;
              RS_rs1_ROB[3] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[3] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[3] <= rob_pos_from_issue;
              RS_pc[3] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[4]) begin
              RS_in_use[4] <= `BUSY;
              RS_opcode[4] <= opcode_from_issue;
              RS_imm[4] <= imm_from_issue;
              RS_funct7[4] <= funct7_from_issue;
              RS_funct3[4] <= funct3_from_issue;
              RS_rs1_ready[4] <= rs1_rdy_from_issue;
              RS_rs2_ready[4] <= rs2_rdy_from_issue;
              RS_rs1_data[4] <= rs1_from_issue;
              RS_rs2_data[4] <= rs2_from_issue;
              RS_rs1_ROB[4] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[4] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[4] <= rob_pos_from_issue;
              RS_pc[4] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[5]) begin
              RS_in_use[5] <= `BUSY;
              RS_opcode[5] <= opcode_from_issue;
              RS_imm[5] <= imm_from_issue;
              RS_funct7[5] <= funct7_from_issue;
              RS_funct3[5] <= funct3_from_issue;
              RS_rs1_ready[5] <= rs1_rdy_from_issue;
              RS_rs2_ready[5] <= rs2_rdy_from_issue;
              RS_rs1_data[5] <= rs1_from_issue;
              RS_rs2_data[5] <= rs2_from_issue;
              RS_rs1_ROB[5] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[5] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[5] <= rob_pos_from_issue;
              RS_pc[5] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[6]) begin
              RS_in_use[6] <= `BUSY;
              RS_opcode[6] <= opcode_from_issue;
              RS_imm[6] <= imm_from_issue;
              RS_funct7[6] <= funct7_from_issue;
              RS_funct3[6] <= funct3_from_issue;
              RS_rs1_ready[6] <= rs1_rdy_from_issue;
              RS_rs2_ready[6] <= rs2_rdy_from_issue;
              RS_rs1_data[6] <= rs1_from_issue;
              RS_rs2_data[6] <= rs2_from_issue;
              RS_rs1_ROB[6] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[6] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[6] <= rob_pos_from_issue;
              RS_pc[6] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[7]) begin
              RS_in_use[7] <= `BUSY;
              RS_opcode[7] <= opcode_from_issue;
              RS_imm[7] <= imm_from_issue;
              RS_funct7[7] <= funct7_from_issue;
              RS_funct3[7] <= funct3_from_issue;
              RS_rs1_ready[7] <= rs1_rdy_from_issue;
              RS_rs2_ready[7] <= rs2_rdy_from_issue;
              RS_rs1_data[7] <= rs1_from_issue;
              RS_rs2_data[7] <= rs2_from_issue;
              RS_rs1_ROB[7] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[7] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[7] <= rob_pos_from_issue;
              RS_pc[7] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[8]) begin
              RS_in_use[8] <= `BUSY;
              RS_opcode[8] <= opcode_from_issue;
              RS_imm[8] <= imm_from_issue;
              RS_funct7[8] <= funct7_from_issue;
              RS_funct3[8] <= funct3_from_issue;
              RS_rs1_ready[8] <= rs1_rdy_from_issue;
              RS_rs2_ready[8] <= rs2_rdy_from_issue;
              RS_rs1_data[8] <= rs1_from_issue;
              RS_rs2_data[8] <= rs2_from_issue;
              RS_rs1_ROB[8] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[8] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[8] <= rob_pos_from_issue;
              RS_pc[8] <= inst_addr_from_issue;             
           end 
           else if(!RS_in_use[9]) begin
              RS_in_use[9] <= `BUSY;
              RS_opcode[9] <= opcode_from_issue;
              RS_imm[9] <= imm_from_issue;
              RS_funct7[9] <= funct7_from_issue;
              RS_funct3[9] <= funct3_from_issue;
              RS_rs1_ready[9] <= rs1_rdy_from_issue;
              RS_rs2_ready[9] <= rs2_rdy_from_issue;
              RS_rs1_data[9] <= rs1_from_issue;
              RS_rs2_data[9] <= rs2_from_issue;
              RS_rs1_ROB[9] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[9] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[9] <= rob_pos_from_issue;
              RS_pc[9] <= inst_addr_from_issue;             
           end  
           else if(!RS_in_use[10]) begin
              RS_in_use[10] <= `BUSY;
              RS_opcode[10] <= opcode_from_issue;
              RS_imm[10] <= imm_from_issue;
              RS_funct7[10] <= funct7_from_issue;
              RS_funct3[10] <= funct3_from_issue;
              RS_rs1_ready[10] <= rs1_rdy_from_issue;
              RS_rs2_ready[10] <= rs2_rdy_from_issue;
              RS_rs1_data[10] <= rs1_from_issue;
              RS_rs2_data[10] <= rs2_from_issue;
              RS_rs1_ROB[10] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[10] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[10] <= rob_pos_from_issue;
              RS_pc[10] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[11]) begin
              RS_in_use[11] <= `BUSY;
              RS_opcode[11] <= opcode_from_issue;
              RS_imm[11] <= imm_from_issue;
              RS_funct7[11] <= funct7_from_issue;
              RS_funct3[11] <= funct3_from_issue;
              RS_rs1_ready[11] <= rs1_rdy_from_issue;
              RS_rs2_ready[11] <= rs2_rdy_from_issue;
              RS_rs1_data[11] <= rs1_from_issue;
              RS_rs2_data[11] <= rs2_from_issue;
              RS_rs1_ROB[11] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[11] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[11] <= rob_pos_from_issue;
              RS_pc[11] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[12]) begin
              RS_in_use[12] <= `BUSY;
              RS_opcode[12] <= opcode_from_issue;
              RS_imm[12] <= imm_from_issue;
              RS_funct7[12] <= funct7_from_issue;
              RS_funct3[12] <= funct3_from_issue;
              RS_rs1_ready[12] <= rs1_rdy_from_issue;
              RS_rs2_ready[12] <= rs2_rdy_from_issue;
              RS_rs1_data[12] <= rs1_from_issue;
              RS_rs2_data[12] <= rs2_from_issue;
              RS_rs1_ROB[12] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[12] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[12] <= rob_pos_from_issue;
              RS_pc[12] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[13]) begin
              RS_in_use[13] <= `BUSY;
              RS_opcode[13] <= opcode_from_issue;
              RS_imm[13] <= imm_from_issue;
              RS_funct7[13] <= funct7_from_issue;
              RS_funct3[13] <= funct3_from_issue;
              RS_rs1_ready[13] <= rs1_rdy_from_issue;
              RS_rs2_ready[13] <= rs2_rdy_from_issue;
              RS_rs1_data[13] <= rs1_from_issue;
              RS_rs2_data[13] <= rs2_from_issue;
              RS_rs1_ROB[13] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[13] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[13] <= rob_pos_from_issue;
              RS_pc[13] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[14]) begin
              RS_in_use[14] <= `BUSY;
              RS_opcode[14] <= opcode_from_issue;
              RS_imm[14] <= imm_from_issue;
              RS_funct7[14] <= funct7_from_issue;
              RS_funct3[14] <= funct3_from_issue;
              RS_rs1_ready[14] <= rs1_rdy_from_issue;
              RS_rs2_ready[14] <= rs2_rdy_from_issue;
              RS_rs1_data[14] <= rs1_from_issue;
              RS_rs2_data[14] <= rs2_from_issue;
              RS_rs1_ROB[14] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[14] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[14] <= rob_pos_from_issue;
              RS_pc[14] <= inst_addr_from_issue;             
           end
           else if(!RS_in_use[15]) begin
              RS_in_use[15] <= `BUSY;
              RS_opcode[15] <= opcode_from_issue;
              RS_imm[15] <= imm_from_issue;
              RS_funct7[15] <= funct7_from_issue;
              RS_funct3[15] <= funct3_from_issue;
              RS_rs1_ready[15] <= rs1_rdy_from_issue;
              RS_rs2_ready[15] <= rs2_rdy_from_issue;
              RS_rs1_data[15] <= rs1_from_issue;
              RS_rs2_data[15] <= rs2_from_issue;
              RS_rs1_ROB[15] <= rs1_rob_pos_from_issue;
              RS_rs2_ROB[15] <= rs2_rob_pos_from_issue;
              RS_rd_ROB[15] <= rob_pos_from_issue;
              RS_pc[15] <= inst_addr_from_issue;             
           end                              
        end
        if(!(write_from_issue && (rs1_rdy_from_issue || transmit_cdb && rs1_rob_pos_from_issue == rob_pos_cdb || transmit_cdb_sl && rs1_rob_pos_from_issue == rob_pos_cdb_sl) && (rs2_rdy_from_issue || transmit_cdb && rs2_rob_pos_from_issue == rob_pos_cdb || transmit_cdb_sl && rs2_rob_pos_from_issue == rob_pos_cdb_sl))) begin 
           if(RS_in_use[0] && (RS_rs1_ready[0] || transmit_cdb && RS_rs1_ROB[0] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[0] == rob_pos_cdb_sl) && (RS_rs2_ready[0] || transmit_cdb && RS_rs2_ROB[0] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[0] == rob_pos_cdb_sl)) RS_in_use[0] <= `FREE;          
           else if(RS_in_use[1] && (RS_rs1_ready[1] || transmit_cdb && RS_rs1_ROB[1] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[1] == rob_pos_cdb_sl) && (RS_rs2_ready[1] || transmit_cdb && RS_rs2_ROB[1] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[1] == rob_pos_cdb_sl)) RS_in_use[1] <= `FREE;
           else if(RS_in_use[2] && (RS_rs1_ready[2] || transmit_cdb && RS_rs1_ROB[2] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[2] == rob_pos_cdb_sl) && (RS_rs2_ready[2] || transmit_cdb && RS_rs2_ROB[2] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[2] == rob_pos_cdb_sl)) RS_in_use[2] <= `FREE;
           else if(RS_in_use[3] && (RS_rs1_ready[3] || transmit_cdb && RS_rs1_ROB[3] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[3] == rob_pos_cdb_sl) && (RS_rs2_ready[3] || transmit_cdb && RS_rs2_ROB[3] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[3] == rob_pos_cdb_sl)) RS_in_use[3] <= `FREE;
           else if(RS_in_use[4] && (RS_rs1_ready[4] || transmit_cdb && RS_rs1_ROB[4] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[4] == rob_pos_cdb_sl) && (RS_rs2_ready[4] || transmit_cdb && RS_rs2_ROB[4] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[4] == rob_pos_cdb_sl)) RS_in_use[4] <= `FREE;
           else if(RS_in_use[5] && (RS_rs1_ready[5] || transmit_cdb && RS_rs1_ROB[5] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[5] == rob_pos_cdb_sl) && (RS_rs2_ready[5] || transmit_cdb && RS_rs2_ROB[5] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[5] == rob_pos_cdb_sl)) RS_in_use[5] <= `FREE;
           else if(RS_in_use[6] && (RS_rs1_ready[6] || transmit_cdb && RS_rs1_ROB[6] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[6] == rob_pos_cdb_sl) && (RS_rs2_ready[6] || transmit_cdb && RS_rs2_ROB[6] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[6] == rob_pos_cdb_sl)) RS_in_use[6] <= `FREE;
           else if(RS_in_use[7] && (RS_rs1_ready[7] || transmit_cdb && RS_rs1_ROB[7] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[7] == rob_pos_cdb_sl) && (RS_rs2_ready[7] || transmit_cdb && RS_rs2_ROB[7] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[7] == rob_pos_cdb_sl)) RS_in_use[7] <= `FREE;
           else if(RS_in_use[8] && (RS_rs1_ready[8] || transmit_cdb && RS_rs1_ROB[8] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[8] == rob_pos_cdb_sl) && (RS_rs2_ready[8] || transmit_cdb && RS_rs2_ROB[8] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[8] == rob_pos_cdb_sl)) RS_in_use[8] <= `FREE;
           else if(RS_in_use[9] && (RS_rs1_ready[9] || transmit_cdb && RS_rs1_ROB[9] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[9] == rob_pos_cdb_sl) && (RS_rs2_ready[9] || transmit_cdb && RS_rs2_ROB[9] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[9] == rob_pos_cdb_sl)) RS_in_use[9] <= `FREE;
           else if(RS_in_use[10] && (RS_rs1_ready[10] || transmit_cdb && RS_rs1_ROB[10] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[10] == rob_pos_cdb_sl) && (RS_rs2_ready[10] || transmit_cdb && RS_rs2_ROB[10] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[10] == rob_pos_cdb_sl)) RS_in_use[10] <= `FREE;
           else if(RS_in_use[11] && (RS_rs1_ready[11] || transmit_cdb && RS_rs1_ROB[11] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[11] == rob_pos_cdb_sl) && (RS_rs2_ready[11] || transmit_cdb && RS_rs2_ROB[11] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[11] == rob_pos_cdb_sl)) RS_in_use[11] <= `FREE;
           else if(RS_in_use[12] && (RS_rs1_ready[12] || transmit_cdb && RS_rs1_ROB[12] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[12] == rob_pos_cdb_sl) && (RS_rs2_ready[12] || transmit_cdb && RS_rs2_ROB[12] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[12] == rob_pos_cdb_sl)) RS_in_use[12] <= `FREE;
           else if(RS_in_use[13] && (RS_rs1_ready[13] || transmit_cdb && RS_rs1_ROB[13] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[13] == rob_pos_cdb_sl) && (RS_rs2_ready[13] || transmit_cdb && RS_rs2_ROB[13] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[13] == rob_pos_cdb_sl)) RS_in_use[13] <= `FREE;
           else if(RS_in_use[14] && (RS_rs1_ready[14] || transmit_cdb && RS_rs1_ROB[14] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[14] == rob_pos_cdb_sl) && (RS_rs2_ready[14] || transmit_cdb && RS_rs2_ROB[14] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[14] == rob_pos_cdb_sl)) RS_in_use[14] <= `FREE;
           else if(RS_in_use[15] && (RS_rs1_ready[15] || transmit_cdb && RS_rs1_ROB[15] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[15] == rob_pos_cdb_sl) && (RS_rs2_ready[11] || transmit_cdb && RS_rs2_ROB[15] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[15] == rob_pos_cdb_sl)) RS_in_use[15] <= `FREE;  
        end
    end
end

always @ (posedge clk_in) begin
    if (rst_in || flush_from_commit) transmit_to_ex <= `TRANSMIT_DISABLE;
    else if(rdy_in) begin
      if(write_from_issue && (rs1_rdy_from_issue || transmit_cdb && rs1_rob_pos_from_issue == rob_pos_cdb || transmit_cdb_sl && rs1_rob_pos_from_issue == rob_pos_cdb_sl) && (rs2_rdy_from_issue || transmit_cdb && rs2_rob_pos_from_issue == rob_pos_cdb || transmit_cdb_sl && rs2_rob_pos_from_issue == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= imm_from_issue;
       inst_addr_to_ex <= inst_addr_from_issue;
       opcode_to_ex <= opcode_from_issue;
       funct7_to_ex <= funct7_from_issue;
       funct3_to_ex <= funct3_from_issue;
       rob_pos_to_ex <= rob_pos_from_issue;
       if (rs1_rdy_from_issue) rs1_to_ex <= rs1_from_issue;
       else if (transmit_cdb && rs1_rob_pos_from_issue == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && rs1_rob_pos_from_issue == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (rs2_rdy_from_issue) rs2_to_ex <= rs2_from_issue;
       else if (transmit_cdb && rs2_rob_pos_from_issue == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && rs2_rob_pos_from_issue == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[0] && (RS_rs1_ready[0] || transmit_cdb && RS_rs1_ROB[0] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[0] == rob_pos_cdb_sl) && (RS_rs2_ready[0] || transmit_cdb && RS_rs2_ROB[0] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[0] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[0];
       inst_addr_to_ex <= RS_pc[0];
       opcode_to_ex <= RS_opcode[0];
       funct7_to_ex <= RS_funct7[0];
       funct3_to_ex <= RS_funct3[0];
       rob_pos_to_ex <= RS_rd_ROB[0];
       if (RS_rs1_ready[0]) rs1_to_ex <= RS_rs1_data[0];
       else if (transmit_cdb && RS_rs1_ROB[0] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[0] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[0]) rs2_to_ex <= RS_rs2_data[0];
       else if (transmit_cdb && RS_rs2_ROB[0] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[0] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[1] && (RS_rs1_ready[1] || transmit_cdb && RS_rs1_ROB[1] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[1] == rob_pos_cdb_sl) && (RS_rs2_ready[1] || transmit_cdb && RS_rs2_ROB[1] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[1] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[1];
       inst_addr_to_ex <= RS_pc[1];
       opcode_to_ex <= RS_opcode[1];
       funct7_to_ex <= RS_funct7[1];
       funct3_to_ex <= RS_funct3[1];
       rob_pos_to_ex <= RS_rd_ROB[1];
       if (RS_rs1_ready[1]) rs1_to_ex <= RS_rs1_data[1];
       else if (transmit_cdb && RS_rs1_ROB[1] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[1] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;       
       if (RS_rs2_ready[1]) rs2_to_ex <= RS_rs2_data[1];
       else if (transmit_cdb && RS_rs2_ROB[1] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[1] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[2] && (RS_rs1_ready[2] || transmit_cdb && RS_rs1_ROB[2] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[2] == rob_pos_cdb_sl) && (RS_rs2_ready[2] || transmit_cdb && RS_rs2_ROB[2] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[2] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[2];
       inst_addr_to_ex <= RS_pc[2];
       opcode_to_ex <= RS_opcode[2];
       funct7_to_ex <= RS_funct7[2];
       funct3_to_ex <= RS_funct3[2];
       rob_pos_to_ex <= RS_rd_ROB[2];
       if (RS_rs1_ready[2]) rs1_to_ex <= RS_rs1_data[2];
       else if (transmit_cdb && RS_rs1_ROB[2] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[2] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[2]) rs2_to_ex <= RS_rs2_data[2];
       else if (transmit_cdb && RS_rs2_ROB[2] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[2] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[3] && (RS_rs1_ready[3] || transmit_cdb && RS_rs1_ROB[3] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[3] == rob_pos_cdb_sl) && (RS_rs2_ready[3] || transmit_cdb && RS_rs2_ROB[3] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[3] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[3];
       inst_addr_to_ex <= RS_pc[3];
       opcode_to_ex <= RS_opcode[3];
       funct7_to_ex <= RS_funct7[3];
       funct3_to_ex <= RS_funct3[3];
       rob_pos_to_ex <= RS_rd_ROB[3];
       if (RS_rs1_ready[3]) rs1_to_ex <= RS_rs1_data[3];
       else if (transmit_cdb && RS_rs1_ROB[3] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[3] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[3]) rs2_to_ex <= RS_rs2_data[3];
       else if (transmit_cdb && RS_rs2_ROB[3] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[3] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[4] && (RS_rs1_ready[4] || transmit_cdb && RS_rs1_ROB[4] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[4] == rob_pos_cdb_sl) && (RS_rs2_ready[4] || transmit_cdb && RS_rs2_ROB[4] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[4] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[4];
       inst_addr_to_ex <= RS_pc[4];
       opcode_to_ex <= RS_opcode[4];
       funct7_to_ex <= RS_funct7[4];
       funct3_to_ex <= RS_funct3[4];
       rob_pos_to_ex <= RS_rd_ROB[4];
       if (RS_rs1_ready[4]) rs1_to_ex <= RS_rs1_data[4];
       else if (transmit_cdb && RS_rs1_ROB[4] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[4] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;       
       if (RS_rs2_ready[4]) rs2_to_ex <= RS_rs2_data[4];
       else if (transmit_cdb && RS_rs2_ROB[4] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[4] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[5] && (RS_rs1_ready[5] || transmit_cdb && RS_rs1_ROB[5] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[5] == rob_pos_cdb_sl) && (RS_rs2_ready[5] || transmit_cdb && RS_rs2_ROB[5] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[5] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[5];
       inst_addr_to_ex <= RS_pc[5];
       opcode_to_ex <= RS_opcode[5];
       funct7_to_ex <= RS_funct7[5];
       funct3_to_ex <= RS_funct3[5];
       rob_pos_to_ex <= RS_rd_ROB[5];
       if (RS_rs1_ready[5]) rs1_to_ex <= RS_rs1_data[5];
       else if (transmit_cdb && RS_rs1_ROB[5] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[5] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;    
       if (RS_rs2_ready[5]) rs2_to_ex <= RS_rs2_data[5];
       else if (transmit_cdb && RS_rs2_ROB[5] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[5] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[6] && (RS_rs1_ready[6] || transmit_cdb && RS_rs1_ROB[6] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[6] == rob_pos_cdb_sl) && (RS_rs2_ready[6] || transmit_cdb && RS_rs2_ROB[6] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[6] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[6];
       inst_addr_to_ex <= RS_pc[6];
       opcode_to_ex <= RS_opcode[6];
       funct7_to_ex <= RS_funct7[6];
       funct3_to_ex <= RS_funct3[6];
       rob_pos_to_ex <= RS_rd_ROB[6];
       if (RS_rs1_ready[6]) rs1_to_ex <= RS_rs1_data[6];
       else if (transmit_cdb && RS_rs1_ROB[6] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[6] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[6]) rs2_to_ex <= RS_rs2_data[6];
       else if (transmit_cdb && RS_rs2_ROB[6] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[6] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[7] && (RS_rs1_ready[7] || transmit_cdb && RS_rs1_ROB[7] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[7] == rob_pos_cdb_sl) && (RS_rs2_ready[7] || transmit_cdb && RS_rs2_ROB[7] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[7] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[7];
       inst_addr_to_ex <= RS_pc[7];
       opcode_to_ex <= RS_opcode[7];
       funct7_to_ex <= RS_funct7[7];
       funct3_to_ex <= RS_funct3[7];
       rob_pos_to_ex <= RS_rd_ROB[7];
       if (RS_rs1_ready[7]) rs1_to_ex <= RS_rs1_data[7];
       else if (transmit_cdb && RS_rs1_ROB[7] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[7] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[7]) rs2_to_ex <= RS_rs2_data[7];
       else if (transmit_cdb && RS_rs2_ROB[7] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[7] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[8] && (RS_rs1_ready[8] || transmit_cdb && RS_rs1_ROB[8] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[8] == rob_pos_cdb_sl) && (RS_rs2_ready[8] || transmit_cdb && RS_rs2_ROB[8] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[8] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[8];
       inst_addr_to_ex <= RS_pc[8];
       opcode_to_ex <= RS_opcode[8];
       funct7_to_ex <= RS_funct7[8];
       funct3_to_ex <= RS_funct3[8];
       rob_pos_to_ex <= RS_rd_ROB[8];
       if (RS_rs1_ready[8]) rs1_to_ex <= RS_rs1_data[8];
       else if (transmit_cdb && RS_rs1_ROB[8] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[8] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[8]) rs2_to_ex <= RS_rs2_data[8];
       else if (transmit_cdb && RS_rs2_ROB[8] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[8] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[9] && (RS_rs1_ready[9] || transmit_cdb && RS_rs1_ROB[9] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[9] == rob_pos_cdb_sl) && (RS_rs2_ready[9] || transmit_cdb && RS_rs2_ROB[9] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[9] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[9];
       inst_addr_to_ex <= RS_pc[9];
       opcode_to_ex <= RS_opcode[9];
       funct7_to_ex <= RS_funct7[9];
       funct3_to_ex <= RS_funct3[9];
       rob_pos_to_ex <= RS_rd_ROB[9];
       if (RS_rs1_ready[9]) rs1_to_ex <= RS_rs1_data[9];
       else if (transmit_cdb && RS_rs1_ROB[9] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[9] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[9]) rs2_to_ex <= RS_rs2_data[9];
       else if (transmit_cdb && RS_rs2_ROB[9] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[9] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[10] && (RS_rs1_ready[10] || transmit_cdb && RS_rs1_ROB[10] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[10] == rob_pos_cdb_sl) && (RS_rs2_ready[10] || transmit_cdb && RS_rs2_ROB[10] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[10] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[10];
       inst_addr_to_ex <= RS_pc[10];
       opcode_to_ex <= RS_opcode[10];
       funct7_to_ex <= RS_funct7[10];
       funct3_to_ex <= RS_funct3[10];
       rob_pos_to_ex <= RS_rd_ROB[10];
       if (RS_rs1_ready[10]) rs1_to_ex <= RS_rs1_data[10];
       else if (transmit_cdb && RS_rs1_ROB[10] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[10] == rob_pos_cdb_sl)  rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[10]) rs2_to_ex <= RS_rs2_data[10];
       else if (transmit_cdb && RS_rs2_ROB[10] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[10] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[11] && (RS_rs1_ready[11] || transmit_cdb && RS_rs1_ROB[11] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[11] == rob_pos_cdb_sl) && (RS_rs2_ready[11] || transmit_cdb && RS_rs2_ROB[11] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[11] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[11];
       inst_addr_to_ex <= RS_pc[11];
       opcode_to_ex <= RS_opcode[11];
       funct7_to_ex <= RS_funct7[11];
       funct3_to_ex <= RS_funct3[11];
       rob_pos_to_ex <= RS_rd_ROB[11];
       if (RS_rs1_ready[11]) rs1_to_ex <= RS_rs1_data[11];
       else if (transmit_cdb && RS_rs1_ROB[11] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[11] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[11]) rs2_to_ex <= RS_rs2_data[11];
       else if (transmit_cdb && RS_rs2_ROB[11] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[11] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[12] && (RS_rs1_ready[12] || transmit_cdb && RS_rs1_ROB[12] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[12] == rob_pos_cdb_sl) && (RS_rs2_ready[12] || transmit_cdb && RS_rs2_ROB[12] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[12] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[12];
       inst_addr_to_ex <= RS_pc[12];
       opcode_to_ex <= RS_opcode[12];
       funct7_to_ex <= RS_funct7[12];
       funct3_to_ex <= RS_funct3[12];
       rob_pos_to_ex <= RS_rd_ROB[12];
       if (RS_rs1_ready[12]) rs1_to_ex <= RS_rs1_data[12];
       else if (transmit_cdb && RS_rs1_ROB[12] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[12] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[12]) rs2_to_ex <= RS_rs2_data[12];
       else if (transmit_cdb && RS_rs2_ROB[12] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[12] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[13] && (RS_rs1_ready[13] || transmit_cdb && RS_rs1_ROB[13] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[13] == rob_pos_cdb_sl) && (RS_rs2_ready[13] || transmit_cdb && RS_rs2_ROB[13] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[13] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[13];
       inst_addr_to_ex <= RS_pc[13];
       opcode_to_ex <= RS_opcode[13];
       funct7_to_ex <= RS_funct7[13];
       funct3_to_ex <= RS_funct3[13];
       rob_pos_to_ex <= RS_rd_ROB[13];
       if (RS_rs1_ready[13]) rs1_to_ex <= RS_rs1_data[13];
       else if (transmit_cdb && RS_rs1_ROB[13] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[13] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;  
       if (RS_rs2_ready[13]) rs2_to_ex <= RS_rs2_data[13];
       else if (transmit_cdb && RS_rs2_ROB[13] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[13] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[14] && (RS_rs1_ready[14] || transmit_cdb && RS_rs1_ROB[14] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[14] == rob_pos_cdb_sl) && (RS_rs2_ready[14] || transmit_cdb && RS_rs2_ROB[14] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[14] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[14];
       inst_addr_to_ex <= RS_pc[14];
       opcode_to_ex <= RS_opcode[14];
       funct7_to_ex <= RS_funct7[14];
       funct3_to_ex <= RS_funct3[14];
       rob_pos_to_ex <= RS_rd_ROB[14];
       if (RS_rs1_ready[14]) rs1_to_ex <= RS_rs1_data[14];
       else if (transmit_cdb && RS_rs1_ROB[14] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[14] == rob_pos_cdb_sl) rs1_to_ex <= data_cdb_sl;
       if (RS_rs2_ready[14]) rs2_to_ex <= RS_rs2_data[14];
       else if (transmit_cdb && RS_rs2_ROB[14] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[14] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else if(RS_in_use[15] && (RS_rs1_ready[15] || transmit_cdb && RS_rs1_ROB[15] == rob_pos_cdb || transmit_cdb_sl && RS_rs1_ROB[15] == rob_pos_cdb_sl) && (RS_rs2_ready[15] || transmit_cdb && RS_rs2_ROB[15] == rob_pos_cdb || transmit_cdb_sl && RS_rs2_ROB[15] == rob_pos_cdb_sl)) begin
       transmit_to_ex <= `TRANSMIT_ENABLE;
       imm_to_ex <= RS_imm[15];
       inst_addr_to_ex <= RS_pc[15];
       opcode_to_ex <= RS_opcode[15];
       funct7_to_ex <= RS_funct7[15];
       funct3_to_ex <= RS_funct3[15];
       rob_pos_to_ex <= RS_rd_ROB[15];
       if (RS_rs1_ready[15]) rs1_to_ex <= RS_rs1_data[15];
       else if (transmit_cdb && RS_rs1_ROB[15] == rob_pos_cdb) rs1_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs1_ROB[15] == rob_pos_cdb_sl)  rs1_to_ex <= data_cdb_sl;       
       if (RS_rs2_ready[15]) rs2_to_ex <= RS_rs2_data[15];
       else if (transmit_cdb && RS_rs2_ROB[15] == rob_pos_cdb) rs2_to_ex <= data_cdb;
       else if (transmit_cdb_sl && RS_rs2_ROB[15] == rob_pos_cdb_sl) rs2_to_ex <= data_cdb_sl;
    end
    else begin
       transmit_to_ex <= `TRANSMIT_DISABLE;
    end
   end
end
endmodule 