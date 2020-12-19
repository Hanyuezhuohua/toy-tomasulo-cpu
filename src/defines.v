`ifndef defined_constant
`define defined_constant

`define INST_WIDTH   31:0
`define DATA_WIDTH   31:0 
`define SHAMT_WIDTH  4:0
`define OPCODE_WIDTH 6:0
`define FUNCT7_WIDTH 6:0 
`define FUNCT3_WIDTH 2:0
`define ROB_WIDTH    4:0
`define ADDR_WIDTH   31:0
`define INST_CACHE_CAPCITY 511:0
`define INST_ADDR_INDEX_RANGE 10:2
`define INST_ADDR_INDEX_WIDTH 8:0
`define INST_ADDR_TAG_RANGE 31:11
`define INST_ADDR_TAG_WIDTH 20:0
`define REGFILE_WIDTH 4:0
`define REGFILE_CAPCITY 31:0
`define SLBUFFER_CAPCITY 31:0
`define ROB_CAPCITY 31:0
`define RAM_DATA_LENGTH 7:0
`define RESERVE_STATION_WIDTH 15:0
`define INST_QUEUE_CAPCITY 31:0
`define POINTER_WIDTH 4:0
`define RW_DATA_WIDTH 2:0
`define RW_STAGE_WIDTH 2:0
`define RD_RANGE 11:7
`define OPCODE_RANGE 6:0
`define RS1_RANGE 19:15
`define RS2_RANGE 24:20
`define FUNCT7_RANGE 31:25
`define FUNCT3_RANGE 14:12
`define MOD_WIDTH 4:0
`define LONG_POINTER_WIDTH 31:0
`define TYPE_WIDTH 1:0

`define ZERO_DATA 32'b0
`define ZERO_ADDR 32'b0
`define ZERO_INST 32'b0
`define ZERO_ROB  5'b0
`define ZERO_REGFILE 5'b0
`define ZERO_POINTER 1'b0
`define ZERO_OPCODE  7'b0
`define ZERO_FUNCT7  7'b0
`define ZERO_FUNCT3  3'b0

`define INST_QUEUE_FULL_LENGTH 5'b11101
`define SLBUFFER_FULL_LENGTH   5'b11100
`define ROB_FULL_LENGTH        5'b11101

`define VALID 1'b1
`define INVALID 1'b0
`define FULL 1'b1
`define NOT_FULL 1'b0
`define EMPTY 1'b1
`define NOT_EMPTY 1'b0
`define RAM_WRITE 1'b1
`define RAM_READ  1'b0

`define S0 3'b000
`define S1 3'b001
`define S2 3'b010
`define S3 3'b011
`define S4 3'b100
`define S0_WRITE_RANGE 7:0
`define S1_WRITE_RANGE 15:8
`define S2_WRITE_RANGE 23:16
`define S3_WRITE_RANGE 31:24
`define S4_WRITE_DATA  8'b0

`define ZERO_LENGTH 3'b000
`define BYTE_LENGTH 3'b001
`define HALFWORD_LENGTH 3'b010
`define WORD_LENGTH 3'b100

`define ADDR_DISTANCE 32'h4
`define POINTER_DISTANCE  1'b1
`define STAGE_DISTANCE  1'b1

`define JUMP_ENABLE      1'b1
`define JUMP_DISABLE     1'b0
`define TRANSMIT_ENABLE  1'b1
`define TRANSMIT_DISABLE 1'b0
`define WRITE_ENABLE     1'b1
`define WRITE_DISABLE    1'b0
`define FLUSH_ENABLE     1'b1
`define FLUSH_DISABLE    1'b0

`define BUSY 1'b1
`define FREE 1'b0
`define WORK 1'b1
`define IDLE 1'b0
`define READY 1'b1
`define UNAVAILABLE 1'b0

`define LUI_OPCODE            7'b0110111
`define AUIPC_OPCODE          7'b0010111
`define JAL_OPCODE            7'b1101111
`define JALR_OPCODE           7'b1100111
`define BRANCH_OPCODE         7'b1100011
`define LOAD_OPCODE           7'b0000011
`define STORE_OPCODE          7'b0100011
`define ARITHMETIC_IMM_OPCODE 7'b0010011
`define ARITHMETIC_OPCODE     7'b0110011
// opcode

`define JALR_FUNCT3   3'b000 //useless in my inst
`define BEQ_FUNCT3    3'b000
`define BNE_FUNCT3    3'b001
`define BLT_FUNCT3    3'b100
`define BGE_FUNCT3    3'b101
`define BLTU_FUNCT3   3'b110
`define BGEU_FUNCT3   3'b111 //branch_type
`define LB_FUNCT3     3'b000
`define LH_FUNCT3     3'b001
`define LW_FUNCT3     3'b010
`define LBU_FUNCT3    3'b100
`define LHU_FUNCT3    3'b101 //load_type
`define SB_FUNCT3     3'b000
`define SH_FUNCT3     3'b001
`define SW_FUNCT3     3'b010 //store_type
`define ADDI_FUNCT3   3'b000
`define SLTI_FUNCT3   3'b010
`define SLTIU_FUNCT3  3'b011
`define XORI_FUNCT3   3'b100
`define ORI_FUNCT3    3'b110
`define ANDI_FUNCT3   3'b111
`define SLLI_FUNCT3   3'b001
`define SRI_FUNCT3    3'b101 //SRLI&&SRAI || arithmetic_imm_type
`define ADDSUB_FUNCT3 3'b000
`define SLL_FUNCT3    3'b001
`define SLT_FUNCT3    3'b010
`define SLTU_FUNCT3   3'b011
`define XOR_FUNCT3    3'b100
`define SR_FUNCT3     3'b101 //SRL&&SRA
`define OR_FUNCT3     3'b110
`define AND_FUNCT3    3'b111 //arithmetic_type
// funct3

`define SLLI_FUNCT7 7'b0000000 //useless
`define SRLI_FUNCT7 7'b0000000
`define SRAI_FUNCT7 7'b0100000
`define ADD_FUNCT7  7'b0000000
`define SUB_FUNCT7  7'b0100000
`define SLL_FUNCT7  7'b0000000 //useless
`define SLT_FUNCT7  7'b0000000 //uesless
`define SLTU_FUNCT7 7'b0000000 //useless
`define XOR_FUNCT7  7'b0000000 //useless
`define SRL_FUNCT7  7'b0000000
`define SRA_FUNCT7  7'b0100000
`define OR_FUNCT7   7'b0000000 //useless
`define AND_FUNCT7  7'b0000000 //useless
//funct7

`define COMMON_TYPE 2'b00
`define JUMP_TYPE 2'b10
`define SL_TYPE 2'b11
 
`endif

