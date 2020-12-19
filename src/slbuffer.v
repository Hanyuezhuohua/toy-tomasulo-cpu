`include "defines.v"
module SLBUFFER(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    output reg full_to_issue,
    input wire transmit_from_rob,
    input wire write_from_issue,
    input wire[`DATA_WIDTH] rs1_from_issue,
    input wire[`DATA_WIDTH] rs2_from_issue,
    input wire rs1_rdy_from_issue,
    input wire rs2_rdy_from_issue,
    input wire[`ROB_WIDTH] rs1_rob_pos_from_issue,
    input wire[`ROB_WIDTH] rs2_rob_pos_from_issue,
    input wire[`DATA_WIDTH] imm_from_issue,
    input wire[`FUNCT3_WIDTH] funct3_from_issue,
    input wire[`OPCODE_WIDTH] opcode_from_issue,
    input wire[`ROB_WIDTH] rob_pos_from_issue,
    input wire transmit_cdb,
    input wire[`DATA_WIDTH] data_cdb,
    input wire[`ROB_WIDTH] rob_pos_cdb,
    input wire data_rdy_from_memctrl,
    input wire[`DATA_WIDTH] data_from_memctrl,
    output reg transmit_to_memctrl,
    output reg rw_to_memctrl,
    output reg[`ADDR_WIDTH] addr_to_memctrl,
    output reg[`DATA_WIDTH] data_to_memctrl,
    output reg[`RW_DATA_WIDTH] length_to_memctrl,
    output reg transmit_cdb_sl,
    output reg[`ROB_WIDTH] rob_pos_cdb_sl,
    output reg[`DATA_WIDTH] data_cdb_sl,
    input wire flush_from_commit
);

reg[`LONG_POINTER_WIDTH] head_of_rob, tail, head_of_ram_rw;

reg[`DATA_WIDTH] rs1_data[`SLBUFFER_CAPCITY];
reg[`DATA_WIDTH] rs2_data[`SLBUFFER_CAPCITY];
reg rs1_ready_buffer[`SLBUFFER_CAPCITY];
reg rs2_ready_buffer[`SLBUFFER_CAPCITY];
reg[`ROB_WIDTH] rs1_rob_buffer[`SLBUFFER_CAPCITY];
reg[`ROB_WIDTH] rs2_rob_buffer[`SLBUFFER_CAPCITY];
reg[`DATA_WIDTH] imm[`SLBUFFER_CAPCITY];
reg[`FUNCT3_WIDTH] funct3[`SLBUFFER_CAPCITY];
reg[`OPCODE_WIDTH] opcode[`SLBUFFER_CAPCITY];
reg[`ROB_WIDTH] rob[`SLBUFFER_CAPCITY];

integer i;

always @ (posedge clk_in) begin
    if (rst_in) begin
        head_of_rob <= `ZERO_POINTER;
        tail <= `ZERO_POINTER;
        head_of_ram_rw <= `ZERO_POINTER;
        full_to_issue <= `NOT_FULL;
        transmit_cdb_sl <= `TRANSMIT_DISABLE;
    end
    else if (rdy_in) begin
        if (write_from_issue && !flush_from_commit) begin
          if(rs1_rdy_from_issue) begin
             rs1_data[tail[`MOD_WIDTH]] <= rs1_from_issue;
             rs1_ready_buffer[tail[`MOD_WIDTH]] <= rs1_rdy_from_issue;
          end
          else if(transmit_cdb && rob_pos_cdb == rs1_rob_pos_from_issue) begin
            rs1_data[tail[`MOD_WIDTH]] <= data_cdb;
            rs1_ready_buffer[tail[`MOD_WIDTH]] <= `READY;
          end
          else if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs1_rob_pos_from_issue == rob[head_of_rob[`MOD_WIDTH]]) begin
              rs1_ready_buffer[tail[`MOD_WIDTH]] <= `READY;
              case(funct3[head_of_rob[`MOD_WIDTH]])
                 `LB_FUNCT3: rs1_data[tail[`MOD_WIDTH]] <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                 `LH_FUNCT3: rs1_data[tail[`MOD_WIDTH]] <= {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                 `LW_FUNCT3: rs1_data[tail[`MOD_WIDTH]] <= data_from_memctrl;
                 `LBU_FUNCT3: rs1_data[tail[`MOD_WIDTH]] <= {24'b0, data_from_memctrl[7:0]};
                 `LHU_FUNCT3: rs1_data[tail[`MOD_WIDTH]] <= {16'b0, data_from_memctrl[15:0]};
                 default: rs1_data[tail[`MOD_WIDTH]] <= `ZERO_DATA;
              endcase
          end
          else begin
             rs1_ready_buffer[tail[`MOD_WIDTH]] <= rs1_rdy_from_issue;
             rs1_data[tail[`MOD_WIDTH]] <= rs1_from_issue;
          end
          if(rs2_rdy_from_issue) begin
             rs2_data[tail[`MOD_WIDTH]] <= rs2_from_issue;
             rs2_ready_buffer[tail[`MOD_WIDTH]] <= rs2_rdy_from_issue;
          end
          else if(transmit_cdb && rob_pos_cdb == rs2_rob_pos_from_issue) begin
            rs2_data[tail[`MOD_WIDTH]] <= data_cdb;
            rs2_ready_buffer[tail[`MOD_WIDTH]] <= `READY;
          end
          else if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs2_rob_pos_from_issue == rob[head_of_rob[`MOD_WIDTH]]) begin
              rs2_ready_buffer[tail[`MOD_WIDTH]] <= `READY;
              case(funct3[head_of_rob[`MOD_WIDTH]])
                 `LB_FUNCT3: rs2_data[tail[`MOD_WIDTH]] <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                 `LH_FUNCT3: rs2_data[tail[`MOD_WIDTH]] <= {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                 `LW_FUNCT3: rs2_data[tail[`MOD_WIDTH]] <= data_from_memctrl;
                 `LBU_FUNCT3: rs2_data[tail[`MOD_WIDTH]] <= {24'b0, data_from_memctrl[7:0]};
                 `LHU_FUNCT3: rs2_data[tail[`MOD_WIDTH]] <= {16'b0, data_from_memctrl[15:0]};
                 default: rs2_data[tail[`MOD_WIDTH]] <= `ZERO_DATA;
              endcase
          end
          else begin
             rs2_ready_buffer[tail[`MOD_WIDTH]] <= rs2_rdy_from_issue;
             rs2_data[tail[`MOD_WIDTH]] <= rs2_from_issue;
          end
          rs1_rob_buffer[tail[`MOD_WIDTH]] <= rs1_rob_pos_from_issue;
          rs2_rob_buffer[tail[`MOD_WIDTH]] <= rs2_rob_pos_from_issue;
          imm[tail[`MOD_WIDTH]] <= imm_from_issue;
          funct3[tail[`MOD_WIDTH]] <= funct3_from_issue;
          opcode[tail[`MOD_WIDTH]] <= opcode_from_issue;
          rob[tail[`MOD_WIDTH]] <= rob_pos_from_issue;
        end
        for(i = 0; i < 32; i = i + 1) begin
          if(transmit_cdb) begin
            if(!rs1_ready_buffer[i] && rob_pos_cdb == rs1_rob_buffer[i]) begin
              rs1_ready_buffer[i] <= `READY;
              rs1_data[i] <= data_cdb;
            end
            if(!rs2_ready_buffer[i] && rob_pos_cdb == rs2_rob_buffer[i]) begin
              rs2_ready_buffer[i] <= `READY;
              rs2_data[i] <= data_cdb;
            end
          end
          if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE) begin
            if(!rs1_ready_buffer[i] && rs1_rob_buffer[i] == rob[head_of_rob[`MOD_WIDTH]]) begin
              rs1_ready_buffer[i] <= `READY;
              case(funct3[head_of_rob[`MOD_WIDTH]])
                 `LB_FUNCT3: rs1_data[i] <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                 `LH_FUNCT3: rs1_data[i] <= {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                 `LW_FUNCT3: rs1_data[i] <= data_from_memctrl;
                 `LBU_FUNCT3: rs1_data[i] <= {24'b0, data_from_memctrl[7:0]};
                 `LHU_FUNCT3: rs1_data[i] <= {16'b0, data_from_memctrl[15:0]};
                 default: rs1_data[i] <= `ZERO_DATA;
              endcase
            end
            if(!rs2_ready_buffer[i] && rs2_rob_buffer[i] == rob[head_of_rob[`MOD_WIDTH]]) begin
              rs2_ready_buffer[i] <= `READY;
              case(funct3[head_of_rob[`MOD_WIDTH]])
                 `LB_FUNCT3: rs2_data[i] <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                 `LH_FUNCT3: rs2_data[i] <= {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                 `LW_FUNCT3: rs2_data[i] <= data_from_memctrl;
                 `LBU_FUNCT3: rs2_data[i] <= {24'b0, data_from_memctrl[7:0]};
                 `LHU_FUNCT3: rs2_data[i] <= {16'b0, data_from_memctrl[15:0]};
                 default: rs2_data[i] <= `ZERO_DATA;
              endcase
            end
          end
        end
        head_of_rob <= head_of_rob + data_rdy_from_memctrl;
        tail <= flush_from_commit ? head_of_ram_rw + transmit_from_rob : tail + write_from_issue;
        full_to_issue <= tail + write_from_issue - head_of_rob - data_rdy_from_memctrl >= `SLBUFFER_FULL_LENGTH;
        head_of_ram_rw <= head_of_ram_rw + transmit_from_rob;
        if (data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE) begin
            transmit_cdb_sl <= `TRANSMIT_ENABLE;
            rob_pos_cdb_sl <= rob[head_of_rob[`MOD_WIDTH]];
            case (funct3[head_of_rob[`MOD_WIDTH]])
                `LB_FUNCT3: data_cdb_sl <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                `LH_FUNCT3: data_cdb_sl <= {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                `LW_FUNCT3: data_cdb_sl <= data_from_memctrl;
                `LBU_FUNCT3: data_cdb_sl <= {24'b0, data_from_memctrl[7:0]};
                `LHU_FUNCT3: data_cdb_sl <= {16'b0, data_from_memctrl[15:0]};
                default: data_cdb_sl <= `ZERO_DATA;
            endcase
        end
        else if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `STORE_OPCODE) begin
           transmit_cdb_sl <= `TRANSMIT_ENABLE;
           rob_pos_cdb_sl <= rob[head_of_rob[`MOD_WIDTH]];
           data_cdb_sl <= `ZERO_DATA;
        end
        else transmit_cdb_sl <= `TRANSMIT_DISABLE;
    end
end

always @ (*) begin
    if (rst_in) transmit_to_memctrl = `TRANSMIT_DISABLE;
    else begin
        if (head_of_rob + data_rdy_from_memctrl < tail && head_of_rob + data_rdy_from_memctrl < head_of_ram_rw && (rs1_ready_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] || transmit_cdb && rob_pos_cdb == rs1_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] || data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs1_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] == rob[head_of_rob[`MOD_WIDTH]]) && (rs2_ready_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] || transmit_cdb && rob_pos_cdb == rs2_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] || data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs2_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] == rob[head_of_rob[`MOD_WIDTH]])) begin
            if(rs1_ready_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl]) addr_to_memctrl = rs1_data[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
            else if(transmit_cdb && rob_pos_cdb == rs1_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl]) addr_to_memctrl = data_cdb + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
            else if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs1_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] == rob[head_of_rob[`MOD_WIDTH]]) begin
              case (funct3[head_of_rob[`MOD_WIDTH]])
                `LB_FUNCT3: addr_to_memctrl = {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]} + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
                `LH_FUNCT3: addr_to_memctrl = {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]} + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
                `LW_FUNCT3: addr_to_memctrl = data_from_memctrl + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
                `LBU_FUNCT3: addr_to_memctrl = {24'b0, data_from_memctrl[7:0]} + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
                `LHU_FUNCT3: addr_to_memctrl = {16'b0, data_from_memctrl[15:0]} + imm[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
                default: addr_to_memctrl = `ZERO_DATA;
              endcase
            end
            if(rs2_ready_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl]) data_to_memctrl = rs2_data[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl];
            else if(transmit_cdb && rob_pos_cdb == rs2_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl]) data_to_memctrl = data_cdb;
            else if(data_rdy_from_memctrl && opcode[head_of_rob[`MOD_WIDTH]] == `LOAD_OPCODE && rs2_rob_buffer[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] == rob[head_of_rob[`MOD_WIDTH]]) begin
              case (funct3[head_of_rob[`MOD_WIDTH]])
                `LB_FUNCT3: data_to_memctrl = {{24{data_from_memctrl[7]}}, data_from_memctrl[7:0]};
                `LH_FUNCT3: data_to_memctrl = {{16{data_from_memctrl[15]}}, data_from_memctrl[15:0]};
                `LW_FUNCT3: data_to_memctrl = data_from_memctrl;
                `LBU_FUNCT3: data_to_memctrl = {24'b0, data_from_memctrl[7:0]};
                `LHU_FUNCT3: data_to_memctrl = {16'b0, data_from_memctrl[15:0]};
                default: data_to_memctrl = `ZERO_DATA;
              endcase
            end
            transmit_to_memctrl = `TRANSMIT_ENABLE;
            rw_to_memctrl = opcode[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl] == `LOAD_OPCODE ? `RAM_READ : `RAM_WRITE;
            case (funct3[head_of_rob[`MOD_WIDTH] + data_rdy_from_memctrl])
                `LB_FUNCT3: length_to_memctrl = `BYTE_LENGTH;
                `LH_FUNCT3: length_to_memctrl = `HALFWORD_LENGTH;
                `LW_FUNCT3: length_to_memctrl = `WORD_LENGTH;
                `LBU_FUNCT3: length_to_memctrl = `BYTE_LENGTH;
                `LHU_FUNCT3: length_to_memctrl = `HALFWORD_LENGTH;
                default: length_to_memctrl = `ZERO_LENGTH;
            endcase
        end
        else transmit_to_memctrl = `TRANSMIT_DISABLE;
    end
end
endmodule 