`include "defines.v"
module EX(
    input wire clk_in,
    input wire rst_in,
    input wire transmit_from_reservation,
    input wire[`DATA_WIDTH] rs1_from_reservation,
    input wire[`DATA_WIDTH] rs2_from_reservation,
    input wire[`DATA_WIDTH] imm_from_reservation,
    input wire[`ADDR_WIDTH] inst_addr_from_reservation,
    input wire[`OPCODE_WIDTH] opcode_from_reservation,
    input wire[`FUNCT7_WIDTH] funct7_from_reservation,
    input wire[`FUNCT3_WIDTH] funct3_from_reservation,
    input wire[`ROB_WIDTH] rob_pos_from_reservation,

    output reg transmit_cdb,
    output reg[`ROB_WIDTH] rob_pos_cdb,
    output reg[`DATA_WIDTH] data_cdb,
    output reg[`ADDR_WIDTH] jump_addr_cdb,
    output reg jump_cdb
);

always @ (*) begin
    if (rst_in || !transmit_from_reservation) begin
        transmit_cdb = `TRANSMIT_DISABLE;
        rob_pos_cdb = `ZERO_ROB;
        data_cdb = `ZERO_DATA;
        jump_addr_cdb = `ZERO_ADDR;
        jump_cdb = `JUMP_DISABLE;
    end    
    else begin
        transmit_cdb = `TRANSMIT_ENABLE;
        rob_pos_cdb = rob_pos_from_reservation;
        data_cdb = `ZERO_DATA;
        jump_addr_cdb = (opcode_from_reservation == `JAL_OPCODE || opcode_from_reservation == `BRANCH_OPCODE) ? inst_addr_from_reservation + imm_from_reservation : opcode_from_reservation == `JALR_OPCODE ? rs1_from_reservation + imm_from_reservation : `ZERO_ADDR;
        jump_cdb = (opcode_from_reservation == `JAL_OPCODE || opcode_from_reservation == `JALR_OPCODE) ? `JUMP_ENABLE : `JUMP_DISABLE;
        case (opcode_from_reservation)
            `LUI_OPCODE: data_cdb = imm_from_reservation;
            `AUIPC_OPCODE: data_cdb = imm_from_reservation + inst_addr_from_reservation;
            `JAL_OPCODE: data_cdb = inst_addr_from_reservation + `ADDR_DISTANCE;
            `JALR_OPCODE: data_cdb = inst_addr_from_reservation + `ADDR_DISTANCE;  
            `BRANCH_OPCODE: begin
                case (funct3_from_reservation)
                    `BEQ_FUNCT3: jump_cdb = rs1_from_reservation == rs2_from_reservation;
                    `BNE_FUNCT3: jump_cdb = rs1_from_reservation != rs2_from_reservation;
                    `BLT_FUNCT3: jump_cdb = $signed(rs1_from_reservation) < $signed(rs2_from_reservation);
                    `BGE_FUNCT3: jump_cdb = $signed(rs1_from_reservation) >= $signed(rs2_from_reservation);
                    `BLTU_FUNCT3: jump_cdb = rs1_from_reservation < rs2_from_reservation;
                    `BGEU_FUNCT3: jump_cdb = rs1_from_reservation >= rs2_from_reservation;
                    default: ;
                endcase
            end                     
            `ARITHMETIC_IMM_OPCODE: begin
                case (funct3_from_reservation)
                    `ADDI_FUNCT3: data_cdb = rs1_from_reservation + imm_from_reservation;
                    `SLLI_FUNCT3: data_cdb = rs1_from_reservation << imm_from_reservation[`SHAMT_WIDTH];
                    `SLTI_FUNCT3: data_cdb = $signed(rs1_from_reservation) < $signed(imm_from_reservation);
                    `SLTIU_FUNCT3: data_cdb = rs1_from_reservation < imm_from_reservation;
                    `XORI_FUNCT3: data_cdb = rs1_from_reservation ^ imm_from_reservation;
                    `SRI_FUNCT3: data_cdb = (funct7_from_reservation == `SRLI_FUNCT7) ? rs1_from_reservation >> imm_from_reservation[`SHAMT_WIDTH] : rs1_from_reservation >>> imm_from_reservation[`SHAMT_WIDTH];
                    `ORI_FUNCT3: data_cdb = rs1_from_reservation | imm_from_reservation;
                    `ANDI_FUNCT3: data_cdb = rs1_from_reservation & imm_from_reservation;
                    default: ;
                endcase
            end
            `ARITHMETIC_OPCODE: begin
                case (funct3_from_reservation)
                    `ADDSUB_FUNCT3: data_cdb = funct7_from_reservation == `ADD_FUNCT7 ? rs1_from_reservation + rs2_from_reservation : rs1_from_reservation - rs2_from_reservation;
                    `SLL_FUNCT3: data_cdb = rs1_from_reservation << rs2_from_reservation[`SHAMT_WIDTH];
                    `SLT_FUNCT3: data_cdb = $signed(rs1_from_reservation) < $signed(rs2_from_reservation);
                    `SLTU_FUNCT3: data_cdb = rs1_from_reservation < rs2_from_reservation;
                    `XOR_FUNCT3: data_cdb = rs1_from_reservation ^ rs2_from_reservation;
                    `SR_FUNCT3: data_cdb = funct7_from_reservation == `SRL_FUNCT7 ? rs1_from_reservation >> rs2_from_reservation[`SHAMT_WIDTH] : rs1_from_reservation >>> rs2_from_reservation[`SHAMT_WIDTH];
                    `OR_FUNCT3: data_cdb = rs1_from_reservation | rs2_from_reservation;
                    `AND_FUNCT3: data_cdb = rs1_from_reservation & rs2_from_reservation;
                    default: ;
                endcase
            end
            default: ;
        endcase
    end
end

endmodule