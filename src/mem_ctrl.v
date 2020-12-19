`include "defines.v"
module MEM_CTRL(
    input wire clk_in,
    input wire rst_in,
    input wire rdy_in,
    input wire io_buffer_full,

    input wire transmit_from_pc_reg,
    input wire [`ADDR_WIDTH] inst_addr_from_pc_reg,
    output reg inst_rdy_to_pc_reg,
    output reg [`DATA_WIDTH] inst_to_pc_reg,

    input wire transmit_from_slbuffer,
    input wire rw_from_slbuffer,
    input wire[`ADDR_WIDTH] addr_from_slbuffer,
    input wire[`RW_DATA_WIDTH] length_from_slbuffer,
    input wire[`DATA_WIDTH] data_from_slbuffer,
    output reg data_ready_to_slbuffer,
    output reg[`DATA_WIDTH] data_to_slbuffer,
    
    input wire flush_from_commit,

    output wire mem_wr,
    output reg [`ADDR_WIDTH] mem_a,
    output reg [`RAM_DATA_LENGTH] mem_dout,
    input wire [`RAM_DATA_LENGTH] mem_din
);
    reg if_in_use;
    reg mem_in_use; 

    reg [`RW_STAGE_WIDTH] stage;
    reg [`RAM_DATA_LENGTH] inst_tem_storage [`RW_STAGE_WIDTH];
    reg [`RAM_DATA_LENGTH] data_tem_storage [`RW_STAGE_WIDTH];
    
    wire data_reading;
    wire inst_reading;
    wire data_writing;
    
    assign data_reading = transmit_from_slbuffer && !rw_from_slbuffer && !if_in_use;
    assign inst_reading = transmit_from_pc_reg && !mem_in_use;
    assign data_writing = transmit_from_slbuffer && rw_from_slbuffer && !if_in_use && !io_buffer_full;
    assign mem_wr = transmit_from_slbuffer && rw_from_slbuffer && length_from_slbuffer > stage && !if_in_use && !io_buffer_full? `RAM_WRITE : `RAM_READ;

    always @(*) begin
        if (data_reading) mem_a = length_from_slbuffer == stage ? {14'b0, addr_from_slbuffer[17:0]} : addr_from_slbuffer + stage;
        else if (data_writing) begin
            mem_a = length_from_slbuffer == stage ? `ZERO_ADDR : addr_from_slbuffer + stage;
            case (stage)
                `S0:mem_dout = data_from_slbuffer[`S0_WRITE_RANGE];
                `S1:mem_dout = data_from_slbuffer[`S1_WRITE_RANGE];
                `S2:mem_dout = data_from_slbuffer[`S2_WRITE_RANGE];
                `S3:mem_dout = data_from_slbuffer[`S3_WRITE_RANGE];
                `S4:mem_dout = `S4_WRITE_DATA;
            endcase
        end 
        else if (inst_reading) mem_a = inst_addr_from_pc_reg + stage;
        else mem_a = `ZERO_ADDR;
    end
    always @(posedge clk_in) begin
        if (rst_in) begin
            inst_rdy_to_pc_reg <= `UNAVAILABLE; 
            data_ready_to_slbuffer <= `UNAVAILABLE; 
            stage <= `S0; 
            if_in_use <= `IDLE;
            mem_in_use <= `IDLE;
        end 
        else if(rdy_in) begin
        if (data_reading) begin
            if (stage == `S0) begin
                inst_rdy_to_pc_reg <= `UNAVAILABLE; 
                data_ready_to_slbuffer <= `UNAVAILABLE;
                stage <= `S1;
                mem_in_use <= `WORK;
            end 
            else if (stage < length_from_slbuffer) begin
                data_tem_storage[stage - 1] <= mem_din;
                stage <= stage + `STAGE_DISTANCE;
            end 
            else begin
                data_ready_to_slbuffer <= `READY;
                stage <= `S0;
                case (length_from_slbuffer)
                    `BYTE_LENGTH: data_to_slbuffer <= {24'b0, mem_din};
                    `HALFWORD_LENGTH: data_to_slbuffer <= {16'b0, mem_din, data_tem_storage[0]};
                    `WORD_LENGTH: data_to_slbuffer <= {mem_din, data_tem_storage[2], data_tem_storage[1], data_tem_storage[0]};
                endcase
                mem_in_use <= `IDLE;
            end
        end 
        else if (data_writing) begin
            if(stage == `S0) begin
               inst_rdy_to_pc_reg <= `UNAVAILABLE;
               data_ready_to_slbuffer <= `UNAVAILABLE;
               stage <= `S1;
               mem_in_use <= `WORK;          
            end
            else if (stage < length_from_slbuffer) stage <= stage + `STAGE_DISTANCE;
            else begin //maybe can be faster
                data_ready_to_slbuffer <= `READY;
                stage <= `S0;
                data_to_slbuffer <= `ZERO_DATA;
                mem_in_use <= `IDLE;
            end
        end
        else if (inst_reading) begin
            if (flush_from_commit) begin
                inst_rdy_to_pc_reg <= `UNAVAILABLE; 
                data_ready_to_slbuffer <= `UNAVAILABLE;
                stage <= `S0;
                if_in_use <= `IDLE;
            end else if (stage == `S0) begin
                inst_rdy_to_pc_reg <= `UNAVAILABLE; 
                data_ready_to_slbuffer <= `UNAVAILABLE;
                stage <= `S1;
                if_in_use <= `WORK;
            end else if (stage != `S4) begin
                inst_tem_storage[stage-1] <= mem_din;
                stage <= stage+`STAGE_DISTANCE;
            end else begin
                inst_rdy_to_pc_reg <= `READY;
                stage <= `S0;
                inst_to_pc_reg <= {mem_din, inst_tem_storage[2], inst_tem_storage[1], inst_tem_storage[0]};
                if_in_use <= `IDLE;
            end
        end 
        else begin
            inst_rdy_to_pc_reg <= `UNAVAILABLE; 
            data_ready_to_slbuffer <= `UNAVAILABLE;
            if_in_use <= `IDLE;
            mem_in_use <= `IDLE;
            stage <= `S0;
        end
        end
    end
endmodule