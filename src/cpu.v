// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,         // system clock signal
    input  wire                 rst_in,         // reset signal
    input  wire                           rdy_in,         // ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,        // data input bus
    output wire [ 7:0]          mem_dout,       // data output bus
    output wire [31:0]          mem_a,          // address bus (only 17:0 is used)
    output wire                 mem_wr,         // write/read signal (1 for write)
    input  wire                 io_buffer_full, // 1 if uart buffer is full
      output wire [31:0]            dbgreg_dout     // cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)
wire full_from_instqueue_to_pc_reg, jump_from_commit_to_pc_reg;
wire[31:0] jump_addr_from_commit_to_pc_reg;
wire write_from_pc_reg_to_instqueue, transmit_from_issue_to_instqueue;
wire[31:0] inst_from_pc_reg_to_instqueue, inst_addr_from_pc_reg_to_instqueue;
wire rdy_from_memctrl_to_pc_reg;
wire[31:0] inst_from_memctrl_to_pc_reg;
wire data_ready_from_slbuffer_to_memctrl;
wire[31:0] data_from_memctrl_to_slbuffer;
wire transmit_from_pc_reg_to_memctrl;
wire[31:0] inst_addr_from_pc_reg_to_memctrl;
wire transmit_from_slbuffer_to_memctrl, rw_from_slbuffer_to_memctrl;
wire[31:0] addr_from_slbuffer_to_memctrl, data_from_slbuffer_to_memctrl;
wire[2:0] length_from_slbuffer_to_memctrl;
wire empty_from_instqueue_to_issue, full_from_rob_to_issue;
wire[31:0] inst_from_instqueue_to_issue, inst_addr_from_instqueue_to_issue;
wire[4:0] allocated_pos_from_rob_to_issue;
wire full_from_reservation_to_issue;
wire rs1_rdy_from_regfile_to_issue, rs2_rdy_from_regfile_to_issue;
wire[31:0] rs1_from_regfile_to_issue, rs2_from_regfile_to_issue;
wire[4:0] rs1_rob_from_regfile_to_issue, rs2_rob_from_regfile_to_issue;
wire rs1_rdy_from_rob_to_issue, rs2_rdy_from_rob_to_issue;
wire[31:0] rs1_from_rob_to_issue, rs2_from_rob_to_issue;
wire write_from_issue_to_reservation, rs1_rdy_from_issue_to_reservation, rs2_rdy_from_issue_to_reservation;
wire[31:0] rs1_from_issue_to_reservation, rs2_from_issue_to_reservation, imm_from_issue_to_reservation, inst_addr_from_issue_to_reservation;
wire[4:0] rs1_rob_pos_from_issue_to_reservation, rs2_rob_pos_from_issue_to_reservation, rob_pos_from_issue_to_reservation;
wire[6:0] opcode_from_issue_to_reservation, funct7_from_issue_to_reservation;
wire[2:0] funct3_from_issue_to_reservation;
wire write_from_issue_to_slbuffer, rs1_rdy_from_issue_to_slbuffer, rs2_rdy_from_issue_to_slbuffer;
wire[31:0] rs1_from_issue_to_slbuffer, rs2_from_issue_to_slbuffer, imm_from_issue_to_slbuffer;
wire[4:0] rs1_rob_pos_from_issue_to_slbuffer, rs2_rob_pos_from_issue_to_slbuffer, rob_pos_from_issue_to_slbuffer;
wire[6:0] opcode_from_issue_to_slbuffer;
wire[2:0] funct3_from_issue_to_slbuffer;
wire full_from_slbuffer_to_issue;
wire transmit_from_reservation_to_ex;
wire[31:0] rs1_from_reservation_to_ex, rs2_from_reservation_to_ex, imm_from_reservation_to_ex, inst_addr_from_reservation_to_ex;
wire[6:0] opcode_from_reservation_to_ex, funct7_from_reservation_to_ex;
wire[2:0] funct3_from_reservation_to_ex;
wire[4:0] rob_pos_from_reservation_to_ex;
wire rs1_transmit_from_issue_to_regfile, rs2_transmit_from_issue_to_regfile, transmit_from_issue_to_regfile, write_from_commit_to_regfile;
wire[4:0] rs1_pos_from_issue_to_regfile, rs2_pos_from_issue_to_regfile;
wire[4:0] regfile_pos_from_issue_to_regfile, rob_pos_from_issue_to_regfile;
wire[4:0] pos_from_commit_to_regfile, rob_pos_from_commit_to_regfile;
wire[31:0] data_from_commit_to_regfile; 
wire write_from_issue_to_rob, rs1_transmit_from_issue_to_rob, rs2_transmit_from_issue_to_rob;
wire rdy_from_commit_to_rob, rdy_from_issue_to_rob;
wire[4:0] regfile_pos_from_issue_to_rob, rs1_pos_from_issue_to_rob, rs2_pos_from_issue_to_rob;
wire[1:0] type_from_issue_to_rob;
wire transmit_from_rob_to_commit;
wire[4:0] regfile_pos_from_rob_to_commit, rob_pos_from_rob_to_commit;
wire[31:0] data_from_rob_to_commit, jump_addr_from_rob_to_commit;
wire[1:0] type_from_rob_to_commit;
wire jump_from_rob_to_commit;
wire transmit_from_rob_to_slbuffer;
wire transmit_cdb, transmit_cdb_sl;
wire[4:0] rob_pos_cdb, rob_pos_cdb_sl;
wire[31:0] data_cdb, data_cdb_sl;
wire[31:0] jump_addr_cdb;
wire jump_cdb;
wire flush_from_commit;

PC_REG pc_reg(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in),
    .full_from_instqueue(full_from_instqueue_to_pc_reg),
    .write_to_instqueue(write_from_pc_reg_to_instqueue),
    .inst_to_instqueue(inst_from_pc_reg_to_instqueue),
    .inst_addr_to_instqueue(inst_addr_from_pc_reg_to_instqueue),
    .rdy_from_memctrl(rdy_from_memctrl_to_pc_reg),
    .inst_from_memctrl(inst_from_memctrl_to_pc_reg),
    .transmit_to_memctrl(transmit_from_pc_reg_to_memctrl),
    .inst_addr_to_memctrl(inst_addr_from_pc_reg_to_memctrl),
    .jump_from_commit(jump_from_commit_to_pc_reg),
    .jump_addr_from_commit(jump_addr_from_commit_to_pc_reg)
);

INSTQUEUE instqueue(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in),
    .write_from_pc_reg(write_from_pc_reg_to_instqueue),
    .inst_from_pc_reg(inst_from_pc_reg_to_instqueue),
    .inst_addr_from_pc_reg(inst_addr_from_pc_reg_to_instqueue),
    .full_to_pc_reg(full_from_instqueue_to_pc_reg),
    .transmit_from_issue(transmit_from_issue_to_instqueue),
    .inst_to_issue(inst_from_instqueue_to_issue),
    .inst_addr_to_issue(inst_addr_from_instqueue_to_issue),
    .empty_to_issue(empty_from_instqueue_to_issue),
    .flush_from_commit(flush_from_commit)
);

ISSUE issue(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .inst_from_instqueue(inst_from_instqueue_to_issue),
    .inst_addr_from_instqueue(inst_addr_from_instqueue_to_issue),
    .empty_from_instqueue(empty_from_instqueue_to_issue),
    .transmit_to_instqueue(transmit_from_issue_to_instqueue),
    .full_from_reservation(full_from_reservation_to_issue),
    .write_to_reservation(write_from_issue_to_reservation),
    .rs1_to_reservation(rs1_from_issue_to_reservation),
    .rs2_to_reservation(rs2_from_issue_to_reservation),
    .rs1_rdy_to_reservation(rs1_rdy_from_issue_to_reservation),
    .rs2_rdy_to_reservation(rs2_rdy_from_issue_to_reservation),
    .rs1_rob_pos_to_reservation(rs1_rob_pos_from_issue_to_reservation),
    .rs2_rob_pos_to_reservation(rs2_rob_pos_from_issue_to_reservation),
    .imm_to_reservation(imm_from_issue_to_reservation),
    .opcode_to_reservation(opcode_from_issue_to_reservation),
    .funct7_to_reservation(funct7_from_issue_to_reservation),
    .funct3_to_reservation(funct3_from_issue_to_reservation),
    .inst_addr_to_reservation(inst_addr_from_issue_to_reservation),
    .rob_pos_to_reservation(rob_pos_from_issue_to_reservation),
    .full_from_slbuffer(full_from_slbuffer_to_issue),
    .write_to_slbuffer(write_from_issue_to_slbuffer),
    .rs1_to_slbuffer(rs1_from_issue_to_slbuffer),
    .rs2_to_slbuffer(rs2_from_issue_to_slbuffer),
    .rs1_ready_to_slbuffer(rs1_rdy_from_issue_to_slbuffer),
    .rs2_ready_to_slbuffer(rs2_rdy_from_issue_to_slbuffer),
    .rs1_rob_pos_to_slbuffer(rs1_rob_pos_from_issue_to_slbuffer),
    .rs2_rob_pos_to_slbuffer(rs2_rob_pos_from_issue_to_slbuffer),
    .imm_to_slbuffer(imm_from_issue_to_slbuffer),
    .opcode_to_slbuffer(opcode_from_issue_to_slbuffer),
    .funct3_to_slbuffer(funct3_from_issue_to_slbuffer),
    .rob_pos_to_slbuffer(rob_pos_from_issue_to_slbuffer),
    .transmit_to_regfile(transmit_from_issue_to_regfile),
    .regfile_pos_to_regfile(regfile_pos_from_issue_to_regfile),
    .rob_pos_to_regfile(rob_pos_from_issue_to_regfile),
    .rs1_rdy_from_regfile(rs1_rdy_from_regfile_to_issue),
    .rs2_rdy_from_regfile(rs2_rdy_from_regfile_to_issue),
    .rs1_from_regfile(rs1_from_regfile_to_issue),
    .rs2_from_regfile(rs2_from_regfile_to_issue),
    .rs1_rob_from_regfile(rs1_rob_from_regfile_to_issue),
    .rs2_rob_from_regfile(rs2_rob_from_regfile_to_issue),
    .rs1_transmit_to_regfile(rs1_transmit_from_issue_to_regfile),
    .rs2_transmit_to_regfile(rs2_transmit_from_issue_to_regfile),
    .rs1_pos_to_regfile(rs1_pos_from_issue_to_regfile),
    .rs2_pos_to_regfile(rs2_pos_from_issue_to_regfile),                                   
    .rs1_rdy_from_rob(rs1_rdy_from_rob_to_issue),
    .rs2_rdy_from_rob(rs2_rdy_from_rob_to_issue),
    .rs1_from_rob(rs1_from_rob_to_issue),
    .rs2_from_rob(rs2_from_rob_to_issue),
    .full_from_rob(full_from_rob_to_issue),
    .allocated_pos_from_rob(allocated_pos_from_rob_to_issue),
    .regfile_pos_to_rob(regfile_pos_from_issue_to_rob),
    .rs1_transmit_to_rob(rs1_transmit_from_issue_to_rob),
    .rs2_transmit_to_rob(rs2_transmit_from_issue_to_rob),
    .rs1_pos_to_rob(rs1_pos_from_issue_to_rob),
    .rs2_pos_to_rob(rs2_pos_from_issue_to_rob),
    .write_to_rob(write_from_issue_to_rob),
    .rdy_to_rob(rdy_from_issue_to_rob),
    .type_to_rob(type_from_issue_to_rob)
);

RESERVATION resveration(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in),
    .write_from_issue(write_from_issue_to_reservation),
    .rs1_from_issue(rs1_from_issue_to_reservation),
    .rs2_from_issue(rs2_from_issue_to_reservation),
    .rs1_rdy_from_issue(rs1_rdy_from_issue_to_reservation),
    .rs2_rdy_from_issue(rs2_rdy_from_issue_to_reservation),
    .rs1_rob_pos_from_issue(rs1_rob_pos_from_issue_to_reservation),
    .rs2_rob_pos_from_issue(rs2_rob_pos_from_issue_to_reservation),
    .inst_addr_from_issue(inst_addr_from_issue_to_reservation),
    .imm_from_issue(imm_from_issue_to_reservation),
    .opcode_from_issue(opcode_from_issue_to_reservation),
    .funct7_from_issue(funct7_from_issue_to_reservation),
    .funct3_from_issue(funct3_from_issue_to_reservation),
    .rob_pos_from_issue(rob_pos_from_issue_to_reservation),
    .full_to_issue(full_from_reservation_to_issue),
    .transmit_to_ex(transmit_from_reservation_to_ex),
    .rs1_to_ex(rs1_from_reservation_to_ex),
    .rs2_to_ex(rs2_from_reservation_to_ex),
    .imm_to_ex(imm_from_reservation_to_ex),
    .inst_addr_to_ex(inst_addr_from_reservation_to_ex),
    .opcode_to_ex(opcode_from_reservation_to_ex),
    .funct7_to_ex(funct7_from_reservation_to_ex),
    .funct3_to_ex(funct3_from_reservation_to_ex),
    .rob_pos_to_ex(rob_pos_from_reservation_to_ex),
    .transmit_cdb(transmit_cdb),
    .rob_pos_cdb(rob_pos_cdb),
    .data_cdb(data_cdb),
    .transmit_cdb_sl(transmit_cdb_sl),
    .rob_pos_cdb_sl(rob_pos_cdb_sl),
    .data_cdb_sl(data_cdb_sl),
    .flush_from_commit(flush_from_commit)
);

EX ex(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .transmit_from_reservation(transmit_from_reservation_to_ex),
    .rs1_from_reservation(rs1_from_reservation_to_ex),
    .rs2_from_reservation(rs2_from_reservation_to_ex),
    .imm_from_reservation(imm_from_reservation_to_ex),
    .inst_addr_from_reservation(inst_addr_from_reservation_to_ex),
    .opcode_from_reservation(opcode_from_reservation_to_ex),
    .funct7_from_reservation(funct7_from_reservation_to_ex),
    .funct3_from_reservation(funct3_from_reservation_to_ex),
    .rob_pos_from_reservation(rob_pos_from_reservation_to_ex),
    .transmit_cdb(transmit_cdb),
    .rob_pos_cdb(rob_pos_cdb),
    .data_cdb(data_cdb),
    .jump_addr_cdb(jump_addr_cdb),
    .jump_cdb(jump_cdb)
);

ROB rob(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .flush_from_commit(flush_from_commit),
    .rdy_in(rdy_in),
    .full_to_issue(full_from_rob_to_issue),
    .transmit_from_issue(write_from_issue_to_rob),
    .rdy_from_issue(rdy_from_issue_to_rob),
    .regfile_pos_from_issue(regfile_pos_from_issue_to_rob),
    .type_from_issue(type_from_issue_to_rob),
    .allocated_pos_to_issue(allocated_pos_from_rob_to_issue),
    .rdy_from_commit(rdy_from_commit_to_rob),
    .transmit_to_commit(transmit_from_rob_to_commit),
    .rob_pos_to_commit(rob_pos_from_rob_to_commit),
    .regfile_pos_to_commit(regfile_pos_from_rob_to_commit),
    .data_to_commit(data_from_rob_to_commit),
    .jump_addr_to_commit(jump_addr_from_rob_to_commit),
    .type_to_commit(type_from_rob_to_commit),
    .jump_to_commit(jump_from_rob_to_commit),
    .transmit_cdb(transmit_cdb),
    .rob_pos_cdb(rob_pos_cdb),
    .data_cdb(data_cdb),
    .jump_addr_cdb(jump_addr_cdb),
    .jump_cdb(jump_cdb),
    .transmit_cdb_sl(transmit_cdb_sl),
    .rob_pos_cdb_sl(rob_pos_cdb_sl),
    .data_cdb_sl(data_cdb_sl),
    .rs1_transmit_from_issue(rs1_transmit_from_issue_to_rob),
    .rs2_transmit_from_issue(rs2_transmit_from_issue_to_rob),
    .rs1_rob_pos_from_issue(rs1_pos_from_issue_to_rob),
    .rs2_rob_pos_from_issue(rs2_pos_from_issue_to_rob),
    .rs1_to_issue(rs1_from_rob_to_issue),
    .rs2_to_issue(rs2_from_rob_to_issue),
    .rs1_rdy_to_issue(rs1_rdy_from_rob_to_issue),
    .rs2_rdy_to_issue(rs2_rdy_from_rob_to_issue),
    .transmit_to_slbuffer(transmit_from_rob_to_slbuffer)
);

COMMIT commit(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .transmit_from_rob(transmit_from_rob_to_commit),
    .regfile_pos_from_rob(regfile_pos_from_rob_to_commit),
    .rob_pos_from_rob(rob_pos_from_rob_to_commit),
    .data_from_rob(data_from_rob_to_commit),
    .jump_addr_from_rob(jump_addr_from_rob_to_commit),
    .type_from_rob(type_from_rob_to_commit),
    .jump_from_rob(jump_from_rob_to_commit),
    .write_to_regfile(write_from_commit_to_regfile),
    .addr_to_regfile(pos_from_commit_to_regfile),
    .rob_pos_to_regfile(rob_pos_from_commit_to_regfile),
    .data_to_regfile(data_from_commit_to_regfile),
    .transmit_to_rob(rdy_from_commit_to_rob),    
    .flush_from_commit(flush_from_commit),
    .jump_from_commit(jump_from_commit_to_pc_reg),
    .jump_addr_from_commit(jump_addr_from_commit_to_pc_reg)
);

REGFILE regfile(
    .rst_in(rst_in),
    .clk_in(clk_in),
    .rdy_in(rdy_in),
    .transmit_from_issue(transmit_from_issue_to_regfile),
    .pos_from_issue(regfile_pos_from_issue_to_regfile),
    .rob_pos_from_issue(rob_pos_from_issue_to_regfile),
    .write_from_commit(write_from_commit_to_regfile),
    .addr_from_commit(pos_from_commit_to_regfile),
    .rob_pos_from_commit(rob_pos_from_commit_to_regfile),
    .data_from_commit(data_from_commit_to_regfile),
    .rs1_transmit_from_issue(rs1_transmit_from_issue_to_regfile),
    .rs1_pos_from_issue(rs1_pos_from_issue_to_regfile),
    .rs2_transmit_from_issue(rs2_transmit_from_issue_to_regfile),
    .rs2_pos_from_issue(rs2_pos_from_issue_to_regfile),
    .rs1_to_issue(rs1_from_regfile_to_issue),
    .rs1_rdy_to_issue(rs1_rdy_from_regfile_to_issue),
    .rs1_rob_pos_to_issue(rs1_rob_from_regfile_to_issue),
    .rs2_to_issue(rs2_from_regfile_to_issue),
    .rs2_rdy_to_issue(rs2_rdy_from_regfile_to_issue),
    .rs2_rob_pos_to_issue(rs2_rob_from_regfile_to_issue),
    .flush_from_commit(flush_from_commit)
);

SLBUFFER slbuffer(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in),
    .full_to_issue(full_from_slbuffer_to_issue),
    .transmit_from_rob(transmit_from_rob_to_slbuffer),
    .write_from_issue(write_from_issue_to_slbuffer),
    .rs1_from_issue(rs1_from_issue_to_slbuffer),
    .rs2_from_issue(rs2_from_issue_to_slbuffer),
    .rs1_rdy_from_issue(rs1_rdy_from_issue_to_slbuffer),
    .rs2_rdy_from_issue(rs2_rdy_from_issue_to_slbuffer),
    .rs1_rob_pos_from_issue(rs1_rob_pos_from_issue_to_slbuffer),
    .rs2_rob_pos_from_issue(rs2_rob_pos_from_issue_to_slbuffer),
    .imm_from_issue(imm_from_issue_to_slbuffer),
    .funct3_from_issue(funct3_from_issue_to_slbuffer),
    .opcode_from_issue(opcode_from_issue_to_slbuffer),
    .rob_pos_from_issue(rob_pos_from_issue_to_slbuffer),
    .transmit_cdb(transmit_cdb),
    .data_cdb(data_cdb),
    .rob_pos_cdb(rob_pos_cdb),
    .data_rdy_from_memctrl(data_ready_from_slbuffer_to_memctrl),
    .data_from_memctrl(data_from_memctrl_to_slbuffer),
    .transmit_to_memctrl(transmit_from_slbuffer_to_memctrl),
    .rw_to_memctrl(rw_from_slbuffer_to_memctrl),
    .addr_to_memctrl(addr_from_slbuffer_to_memctrl),
    .data_to_memctrl(data_from_slbuffer_to_memctrl),
    .length_to_memctrl(length_from_slbuffer_to_memctrl),
    .transmit_cdb_sl(transmit_cdb_sl),
    .rob_pos_cdb_sl(rob_pos_cdb_sl),
    .data_cdb_sl(data_cdb_sl),
    .flush_from_commit(flush_from_commit)
);

MEM_CTRL mem_ctrl(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in),
    .io_buffer_full(io_buffer_full),
    .transmit_from_pc_reg(transmit_from_pc_reg_to_memctrl),
    .inst_addr_from_pc_reg(inst_addr_from_pc_reg_to_memctrl),
    .inst_rdy_to_pc_reg(rdy_from_memctrl_to_pc_reg),
    .inst_to_pc_reg(inst_from_memctrl_to_pc_reg),
    .transmit_from_slbuffer(transmit_from_slbuffer_to_memctrl),
    .rw_from_slbuffer(rw_from_slbuffer_to_memctrl),
    .addr_from_slbuffer(addr_from_slbuffer_to_memctrl),
    .length_from_slbuffer(length_from_slbuffer_to_memctrl),
    .data_from_slbuffer(data_from_slbuffer_to_memctrl),
    .data_ready_to_slbuffer(data_ready_from_slbuffer_to_memctrl),
    .data_to_slbuffer(data_from_memctrl_to_slbuffer),
    .flush_from_commit(flush_from_commit),
    .mem_wr(mem_wr),
    .mem_a(mem_a),
    .mem_dout(mem_dout),
    .mem_din(mem_din)
);
endmodule