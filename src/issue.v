`include "defines.v"
module ISSUE(
    input wire clk_in,
    input wire rst_in, 
    
    input wire[`INST_WIDTH] inst_from_instqueue,
    input wire[`ADDR_WIDTH] inst_addr_from_instqueue,
    input wire empty_from_instqueue,
    output reg transmit_to_instqueue,
    
    input wire full_from_reservation,
    output reg write_to_reservation,
    output reg[`DATA_WIDTH] rs1_to_reservation,
    output reg[`DATA_WIDTH] rs2_to_reservation,
    output reg rs1_rdy_to_reservation,
    output reg rs2_rdy_to_reservation,
    output reg[`ROB_WIDTH] rs1_rob_pos_to_reservation,
    output reg[`ROB_WIDTH] rs2_rob_pos_to_reservation,
    output reg[`DATA_WIDTH] imm_to_reservation,
    output reg[`OPCODE_WIDTH] opcode_to_reservation,
    output reg[`FUNCT7_WIDTH] funct7_to_reservation,
    output reg[`FUNCT3_WIDTH] funct3_to_reservation,
    output reg[`ADDR_WIDTH] inst_addr_to_reservation,
    output reg[`ROB_WIDTH] rob_pos_to_reservation,

    input wire full_from_slbuffer,
    output reg write_to_slbuffer,
    output reg[`DATA_WIDTH] rs1_to_slbuffer,
    output reg[`DATA_WIDTH] rs2_to_slbuffer,
    output reg rs1_ready_to_slbuffer,
    output reg rs2_ready_to_slbuffer,
    output reg[`ROB_WIDTH] rs1_rob_pos_to_slbuffer,
    output reg[`ROB_WIDTH] rs2_rob_pos_to_slbuffer,
    output reg[`DATA_WIDTH] imm_to_slbuffer,
    output reg[`OPCODE_WIDTH] opcode_to_slbuffer,
    output reg[`FUNCT3_WIDTH] funct3_to_slbuffer,
    output reg[`ROB_WIDTH] rob_pos_to_slbuffer,

    input wire rs1_rdy_from_regfile,
    input wire rs2_rdy_from_regfile,
    input wire[`DATA_WIDTH] rs1_from_regfile,
    input wire[`DATA_WIDTH] rs2_from_regfile,
    input wire[`ROB_WIDTH] rs1_rob_from_regfile,
    input wire[`ROB_WIDTH] rs2_rob_from_regfile,
    output reg rs1_transmit_to_regfile,
    output reg rs2_transmit_to_regfile,
    output reg[`REGFILE_WIDTH] rs1_pos_to_regfile,
    output reg[`REGFILE_WIDTH] rs2_pos_to_regfile,
    output reg transmit_to_regfile,
    output reg[`REGFILE_WIDTH] regfile_pos_to_regfile,
    output reg[`ROB_WIDTH] rob_pos_to_regfile,

    input wire rs1_rdy_from_rob,
    input wire rs2_rdy_from_rob,
    input wire[`DATA_WIDTH] rs1_from_rob,
    input wire[`DATA_WIDTH] rs2_from_rob,
    input wire full_from_rob,
    input wire[`ROB_WIDTH] allocated_pos_from_rob,
    output reg rs1_transmit_to_rob,
    output reg rs2_transmit_to_rob,
    output reg[`ROB_WIDTH] rs1_pos_to_rob,
    output reg[`ROB_WIDTH] rs2_pos_to_rob,
    output reg write_to_rob,
    output reg rdy_to_rob,
    output reg[`REGFILE_WIDTH] regfile_pos_to_rob,
    output reg[`TYPE_WIDTH] type_to_rob
);

wire RS_enable;
wire SLBUFFER_enable;
wire[`DATA_WIDTH] U_IMM, J_IMM, I_IMM, B_IMM, S_IMM;

assign RS_enable = !full_from_rob && !full_from_reservation;
assign SLBUFFER_enable = !full_from_rob && !full_from_slbuffer;
assign U_IMM = {inst_from_instqueue[31:12], 12'b0};
assign J_IMM = {{12{inst_from_instqueue[31]}}, inst_from_instqueue[19:12], inst_from_instqueue[20], inst_from_instqueue[30:21], 1'b0};
assign I_IMM = {{20{inst_from_instqueue[31]}}, inst_from_instqueue[31:20]};
assign B_IMM = {{20{inst_from_instqueue[31]}}, inst_from_instqueue[7], inst_from_instqueue[30:25], inst_from_instqueue[11:8], 1'b0};
assign S_IMM = {{20{inst_from_instqueue[31]}}, inst_from_instqueue[31:25], inst_from_instqueue[11:7]};

always @ (*) begin
    if (rst_in) begin
        transmit_to_instqueue = `TRANSMIT_DISABLE;
        write_to_rob = `WRITE_DISABLE;
        transmit_to_regfile = `WRITE_DISABLE;
        regfile_pos_to_regfile = `ZERO_REGFILE;
        rob_pos_to_regfile = `ZERO_ROB;
        rdy_to_rob = `UNAVAILABLE;
        regfile_pos_to_rob = `ZERO_REGFILE;
        type_to_rob = `COMMON_TYPE;
        rs1_transmit_to_regfile = `TRANSMIT_DISABLE;
        rs1_pos_to_regfile = `ZERO_REGFILE;
        rs1_transmit_to_rob = `TRANSMIT_DISABLE;
        rs1_pos_to_rob = `ZERO_ROB;
        rs2_transmit_to_regfile = `ZERO_REGFILE;
        rs2_pos_to_regfile = `TRANSMIT_DISABLE;
        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
        rs2_pos_to_rob = `ZERO_ROB;
        write_to_reservation = `TRANSMIT_DISABLE;
        rs1_to_reservation = `ZERO_DATA;
        rs2_to_reservation = `ZERO_DATA;
        rs1_rdy_to_reservation = `UNAVAILABLE;
        rs2_rdy_to_reservation = `UNAVAILABLE;
        rs1_rob_pos_to_reservation = `ZERO_ROB;
        rs2_rob_pos_to_reservation = `ZERO_ROB;
        imm_to_reservation = `ZERO_DATA;
        opcode_to_reservation = `ZERO_OPCODE;
        funct7_to_reservation = `ZERO_FUNCT7;
        funct3_to_reservation = `ZERO_FUNCT3;
        inst_addr_to_reservation = `ZERO_ADDR;
        rob_pos_to_reservation = `ZERO_ROB;
        write_to_slbuffer = `TRANSMIT_DISABLE;
        rs1_to_slbuffer = `ZERO_DATA;
        rs2_to_slbuffer = `ZERO_DATA;
        rs1_ready_to_slbuffer = `UNAVAILABLE;
        rs2_ready_to_slbuffer = `UNAVAILABLE;
        rs1_rob_pos_to_slbuffer = `ZERO_ROB;
        rs2_rob_pos_to_slbuffer = `ZERO_ROB;
        imm_to_slbuffer = `ZERO_DATA;
        opcode_to_slbuffer = `ZERO_OPCODE;
        funct3_to_slbuffer = `ZERO_FUNCT3;
        rob_pos_to_slbuffer = `ZERO_ROB;
    end
    else begin
        transmit_to_instqueue = `TRANSMIT_DISABLE;
        write_to_rob = `WRITE_DISABLE;
        transmit_to_regfile = `WRITE_DISABLE;
        regfile_pos_to_regfile = inst_from_instqueue[`RD_RANGE];
        rob_pos_to_regfile = allocated_pos_from_rob;
        rdy_to_rob = `UNAVAILABLE;
        regfile_pos_to_rob = inst_from_instqueue[`RD_RANGE];
        type_to_rob = `COMMON_TYPE;
        rs1_transmit_to_regfile = `TRANSMIT_DISABLE;
        rs1_pos_to_regfile = `ZERO_REGFILE;
        rs1_transmit_to_rob = `TRANSMIT_DISABLE;
        rs1_pos_to_rob = `ZERO_ROB;
        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
        rs2_pos_to_regfile = `ZERO_REGFILE;
        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
        rs2_pos_to_rob = `ZERO_ROB;
        write_to_reservation = `TRANSMIT_DISABLE;
        rs1_to_reservation = `ZERO_DATA;
        rs2_to_reservation = `ZERO_DATA;
        rs1_rdy_to_reservation = `UNAVAILABLE;
        rs2_rdy_to_reservation = `UNAVAILABLE;
        rs1_rob_pos_to_reservation = `ZERO_ROB;
        rs2_rob_pos_to_reservation = `ZERO_ROB;
        imm_to_reservation = `ZERO_DATA;
        opcode_to_reservation = `ZERO_OPCODE;
        funct7_to_reservation = `ZERO_FUNCT7;
        funct3_to_reservation = `ZERO_FUNCT3;
        inst_addr_to_reservation = `ZERO_ADDR;
        rob_pos_to_reservation = `ZERO_ROB;
        write_to_slbuffer = `TRANSMIT_DISABLE;
        rs1_to_slbuffer = `ZERO_DATA;
        rs2_to_slbuffer = `ZERO_DATA;
        rs1_ready_to_slbuffer = `UNAVAILABLE;
        rs2_ready_to_slbuffer = `UNAVAILABLE;
        rs1_rob_pos_to_slbuffer = `ZERO_ROB;
        rs2_rob_pos_to_slbuffer = `ZERO_ROB;
        imm_to_slbuffer = `ZERO_DATA;
        opcode_to_slbuffer = `ZERO_OPCODE;
        funct3_to_slbuffer = `ZERO_FUNCT3;
        rob_pos_to_slbuffer = `ZERO_ROB;
        if (!empty_from_instqueue) begin
            case (inst_from_instqueue[`OPCODE_RANGE])
                `LUI_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs1_pos_to_regfile = `ZERO_REGFILE;
                        rs1_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs1_pos_to_rob = `ZERO_ROB;
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_reservation = `TRANSMIT_ENABLE;
                        rs1_to_reservation = `ZERO_DATA;
                        rs2_to_reservation = `ZERO_DATA;
                        rs1_rdy_to_reservation = `READY;
                        rs2_rdy_to_reservation = `READY;
                        rs1_rob_pos_to_reservation = `ZERO_ROB;
                        rs2_rob_pos_to_reservation = `ZERO_ROB;
                        imm_to_reservation = U_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = `ZERO_FUNCT7;
                        funct3_to_reservation = `ZERO_FUNCT3;
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `AUIPC_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs1_pos_to_regfile = `ZERO_REGFILE;
                        rs1_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs1_pos_to_rob = `ZERO_ROB;
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_reservation = `TRANSMIT_ENABLE;
                        rs1_to_reservation = `ZERO_DATA;
                        rs2_to_reservation = `ZERO_DATA;
                        rs1_rdy_to_reservation = `READY;
                        rs2_rdy_to_reservation = `READY;
                        rs1_rob_pos_to_reservation = `ZERO_ROB;
                        rs2_rob_pos_to_reservation = `ZERO_ROB;
                        imm_to_reservation = U_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = `ZERO_FUNCT7;
                        funct3_to_reservation = `ZERO_FUNCT3;
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `JAL_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        type_to_rob = `JUMP_TYPE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs1_pos_to_regfile = `ZERO_REGFILE;
                        rs1_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs1_pos_to_rob = `ZERO_ROB;
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_reservation = `TRANSMIT_ENABLE;
                        rs1_to_reservation = `ZERO_DATA;
                        rs2_to_reservation = `ZERO_DATA;
                        rs1_rdy_to_reservation = `READY;
                        rs2_rdy_to_reservation = `READY;
                        rs1_rob_pos_to_reservation = `ZERO_ROB;
                        rs2_rob_pos_to_reservation = `ZERO_ROB;
                        imm_to_reservation = J_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = `ZERO_FUNCT7;
                        funct3_to_reservation = `ZERO_FUNCT3;
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `JALR_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        type_to_rob = `JUMP_TYPE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_reservation = rs1_from_regfile;
                          rs1_rdy_to_reservation = `READY;
                          rs1_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_reservation = rs1_from_rob;
                            rs1_rdy_to_reservation = `READY;
                            rs1_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_reservation = `ZERO_DATA;
                            rs1_rdy_to_reservation = `UNAVAILABLE;
                            rs1_rob_pos_to_reservation = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_reservation = `TRANSMIT_ENABLE;
                        rs2_to_reservation = `ZERO_DATA;
                        rs2_rdy_to_reservation = `READY;
                        rs2_rob_pos_to_reservation = `ZERO_ROB;
                        imm_to_reservation = I_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = `ZERO_FUNCT7;
                        funct3_to_reservation = inst_from_instqueue[`FUNCT3_RANGE];
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `BRANCH_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        regfile_pos_to_rob = `ZERO_REGFILE;
                        type_to_rob = `JUMP_TYPE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_reservation = rs1_from_regfile;
                          rs1_rdy_to_reservation = `READY;
                          rs1_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_reservation = rs1_from_rob;
                            rs1_rdy_to_reservation = `READY;
                            rs1_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_reservation = `ZERO_DATA;
                            rs1_rdy_to_reservation = `UNAVAILABLE;
                            rs1_rob_pos_to_reservation = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs2_pos_to_regfile = inst_from_instqueue[`RS2_RANGE];
                        if(rs2_rdy_from_regfile) begin
                          rs2_to_reservation = rs2_from_regfile;
                          rs2_rdy_to_reservation = `READY;
                          rs2_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs2_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs2_pos_to_rob = rs2_rob_from_regfile;
                          if(rs2_rdy_from_rob) begin
                            rs2_to_reservation = rs2_from_rob;
                            rs2_rdy_to_reservation = `READY;
                            rs2_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs2_to_reservation = `ZERO_DATA;
                            rs2_rdy_to_reservation = `UNAVAILABLE;
                            rs2_rob_pos_to_reservation = rs2_rob_from_regfile;
                          end
                        end
                        write_to_reservation = `TRANSMIT_ENABLE;
                        imm_to_reservation = B_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = `ZERO_FUNCT7;
                        funct3_to_reservation = inst_from_instqueue[`FUNCT3_RANGE];
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `LOAD_OPCODE: begin
                    if (SLBUFFER_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        type_to_rob = `SL_TYPE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_slbuffer = rs1_from_regfile;
                          rs1_ready_to_slbuffer = `READY;
                          rs1_rob_pos_to_slbuffer = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_slbuffer = rs1_from_rob;
                            rs1_ready_to_slbuffer = `READY;
                            rs1_rob_pos_to_slbuffer = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_slbuffer = `ZERO_DATA;
                            rs1_ready_to_slbuffer = `UNAVAILABLE;
                            rs1_rob_pos_to_slbuffer = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_slbuffer = `TRANSMIT_ENABLE;
                        rs2_to_slbuffer = `ZERO_DATA;
                        rs2_ready_to_slbuffer = `READY;
                        rs2_rob_pos_to_slbuffer = `ZERO_ROB;
                        imm_to_slbuffer = I_IMM;
                        opcode_to_slbuffer = inst_from_instqueue[`OPCODE_RANGE];
                        funct3_to_slbuffer = inst_from_instqueue[`FUNCT3_RANGE];
                        rob_pos_to_slbuffer = allocated_pos_from_rob;
                    end
                end
                `STORE_OPCODE: begin
                    if (SLBUFFER_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        regfile_pos_to_rob = `ZERO_REGFILE;
                        type_to_rob = `SL_TYPE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_slbuffer = rs1_from_regfile;
                          rs1_ready_to_slbuffer = `READY;
                          rs1_rob_pos_to_slbuffer = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_slbuffer = rs1_from_rob;
                            rs1_ready_to_slbuffer = `READY;
                            rs1_rob_pos_to_slbuffer = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_slbuffer = `ZERO_DATA;
                            rs1_ready_to_slbuffer = `UNAVAILABLE;
                            rs1_rob_pos_to_slbuffer = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs2_pos_to_regfile = inst_from_instqueue[`RS2_RANGE];
                        if(rs2_rdy_from_regfile) begin
                          rs2_to_slbuffer = rs2_from_regfile;
                          rs2_ready_to_slbuffer = `READY;
                          rs2_rob_pos_to_slbuffer = `ZERO_ROB;
                        end
                        else begin
                          rs2_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs2_pos_to_rob = rs2_rob_from_regfile;
                          if(rs2_rdy_from_rob) begin
                            rs2_to_slbuffer = rs2_from_rob;
                            rs2_ready_to_slbuffer = `READY;
                            rs2_rob_pos_to_slbuffer = `ZERO_ROB;
                          end
                          else begin
                            rs2_to_slbuffer = `ZERO_DATA;
                            rs2_ready_to_slbuffer = `UNAVAILABLE;
                            rs2_rob_pos_to_slbuffer = rs2_rob_from_regfile;
                          end
                        end
                        write_to_slbuffer = `TRANSMIT_ENABLE;
                        imm_to_slbuffer = S_IMM;
                        opcode_to_slbuffer = inst_from_instqueue[`OPCODE_RANGE];
                        funct3_to_slbuffer = inst_from_instqueue[`FUNCT3_RANGE];
                        rob_pos_to_slbuffer = allocated_pos_from_rob;
                    end
                end
                `ARITHMETIC_IMM_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_reservation = rs1_from_regfile;
                          rs1_rdy_to_reservation = `READY;
                          rs1_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_reservation = rs1_from_rob;
                            rs1_rdy_to_reservation = `READY;
                            rs1_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_reservation = `ZERO_DATA;
                            rs1_rdy_to_reservation = `UNAVAILABLE;
                            rs1_rob_pos_to_reservation = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_DISABLE;
                        rs2_pos_to_regfile = `ZERO_REGFILE;
                        rs2_transmit_to_rob = `TRANSMIT_DISABLE;
                        rs2_pos_to_rob = `ZERO_ROB;
                        write_to_reservation = `TRANSMIT_ENABLE;
                        rs2_to_reservation = `ZERO_DATA;
                        rs2_rdy_to_reservation = `READY;
                        rs2_rob_pos_to_reservation = `ZERO_ROB;
                        imm_to_reservation = I_IMM;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = inst_from_instqueue[`FUNCT7_RANGE];
                        funct3_to_reservation = inst_from_instqueue[`FUNCT3_RANGE];
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                `ARITHMETIC_OPCODE: begin
                    if (RS_enable) begin
                        transmit_to_instqueue = `TRANSMIT_ENABLE;
                        write_to_rob = `WRITE_ENABLE;
                        transmit_to_regfile = `WRITE_ENABLE;
                        rs1_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs1_pos_to_regfile = inst_from_instqueue[`RS1_RANGE];
                        if(rs1_rdy_from_regfile) begin
                          rs1_to_reservation = rs1_from_regfile;
                          rs1_rdy_to_reservation = `READY;
                          rs1_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs1_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs1_pos_to_rob = rs1_rob_from_regfile;
                          if(rs1_rdy_from_rob) begin
                            rs1_to_reservation = rs1_from_rob;
                            rs1_rdy_to_reservation = `READY;
                            rs1_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs1_to_reservation = `ZERO_DATA;
                            rs1_rdy_to_reservation = `UNAVAILABLE;
                            rs1_rob_pos_to_reservation = rs1_rob_from_regfile;
                          end
                        end
                        rs2_transmit_to_regfile = `TRANSMIT_ENABLE;
                        rs2_pos_to_regfile = inst_from_instqueue[`RS2_RANGE];
                        if(rs2_rdy_from_regfile) begin
                          rs2_to_reservation = rs2_from_regfile;
                          rs2_rdy_to_reservation = `READY;
                          rs2_rob_pos_to_reservation = `ZERO_ROB;
                        end
                        else begin
                          rs2_transmit_to_rob = `TRANSMIT_ENABLE;
                          rs2_pos_to_rob = rs2_rob_from_regfile;
                          if(rs2_rdy_from_rob) begin
                            rs2_to_reservation = rs2_from_rob;
                            rs2_rdy_to_reservation = `READY;
                            rs2_rob_pos_to_reservation = `ZERO_ROB;
                          end
                          else begin
                            rs2_to_reservation = `ZERO_DATA;
                            rs2_rdy_to_reservation = `UNAVAILABLE;
                            rs2_rob_pos_to_reservation = rs2_rob_from_regfile;
                          end
                        end
                        write_to_reservation = `TRANSMIT_ENABLE;
                        imm_to_reservation = `ZERO_DATA;
                        opcode_to_reservation = inst_from_instqueue[`OPCODE_RANGE];
                        funct7_to_reservation = inst_from_instqueue[`FUNCT7_RANGE];
                        funct3_to_reservation = inst_from_instqueue[`FUNCT3_RANGE];
                        inst_addr_to_reservation = inst_addr_from_instqueue;
                        rob_pos_to_reservation = allocated_pos_from_rob;
                    end
                end
                default: ;
            endcase
        end
    end
end

endmodule 