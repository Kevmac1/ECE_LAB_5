// ucsbece154a_controller.v
// All Rights Reserved
// Copyright (c) 2023 UCSB ECE
// Distribution Prohibited

module ucsbece154a_controller (
    input [6:0] op_i,           // Opcode
    input [2:0] funct3_i,       // Function code 3
    input funct7_i,             // Function code 7 (single bit)
    input zero_i,               // Zero flag (from ALU)
    output reg PCWrite_o,       // Control signal to write to PC
    output reg MemWrite_o,      // Control signal to write to memory
    output reg IRWrite_o,       // Control signal to write to instruction register
    output reg RegWrite_o,      // Register write control signal
    output reg ALUSrcA_o,       // ALU source A control signal
    output reg ALUSrcB_o,       // ALU source B control signal
    output reg AdrSrc_o,        // Address source control signal
    output reg ResultSrc_o,     // Result source control signal
    output reg ALUControl_o,    // ALU control signal
    output reg ImmSrc_o         // Immediate source control signal
);

`include "ucsbece154a_defines.vh"

// ********** ALU Control Logic **********
always @ * begin
    case(op_i)
        instr_lw_op:      ALUControl_o = ALUcontrol_add;    // Load instruction
        instr_sw_op:      ALUControl_o = ALUcontrol_add;    // Store instruction
        instr_Rtype_op:   case(funct3_i)
                            instr_addsub_funct3: if (funct7_i) ALUControl_o = ALUcontrol_sub; else ALUControl_o = ALUcontrol_add;
                            instr_slt_funct3: ALUControl_o = ALUcontrol_slt; // Set less than
                            instr_or_funct3: ALUControl_o = ALUcontrol_or;
                            instr_and_funct3: ALUControl_o = ALUcontrol_and;
                            default: ALUControl_o = 3'bxxx;
                        endcase
        instr_beq_op:     ALUControl_o = ALUcontrol_sub;    // Branch equal instruction
        instr_ItypeALU_op: ALUControl_o = ALUcontrol_add;   // I-type ALU instructions
        instr_jal_op:     ALUControl_o = ALUcontrol_add;   // Jump and link instruction
        instr_lui_op:     ALUControl_o = ALUcontrol_add;   // Load upper immediate instruction
        default:          ALUControl_o = 3'bxxx; 
    endcase
end

// ********** Immediate Source Logic **********
always @ * begin
    case (op_i)
        instr_lw_op:      ImmSrc_o = 3'b000;   // I-type load
        instr_sw_op:      ImmSrc_o = 3'b001;   // I-type store
        instr_Rtype_op:   ImmSrc_o = 3'bxxx;   // No immediate in R-type
        instr_beq_op:     ImmSrc_o = 3'b010;   // Immediate for branch
        instr_ItypeALU_op: ImmSrc_o = 3'b000;   // Immediate for I-type ALU
        instr_jal_op:     ImmSrc_o = 3'b011;   // JAL immediate
        instr_lui_op:     ImmSrc_o = 3'b100;   // Load upper immediate
        default:          ImmSrc_o = 3'bxxx;
    endcase
end

// ********** Control Signals **********
always @ * begin
    case (op_i)
        instr_lw_op: begin
            RegWrite_o = 1;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 1;
            ResultSrc_o = 2'b01;
        end
        instr_sw_op: begin
            RegWrite_o = 0;
            MemWrite_o = 1;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 1;
            ResultSrc_o = 2'b00;
        end
        instr_Rtype_op: begin
            RegWrite_o = 1;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 0;
            ResultSrc_o = 2'b00;
        end
        instr_beq_op: begin
            RegWrite_o = 0;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 0;
            ResultSrc_o = 2'b00;
        end
        instr_ItypeALU_op: begin
            RegWrite_o = 1;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 1;
            ResultSrc_o = 2'b00;
        end
        instr_jal_op: begin
            RegWrite_o = 1;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 0;
            ResultSrc_o = 2'b10;
        end
        instr_lui_op: begin
            RegWrite_o = 1;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 1;
            ResultSrc_o = 2'b10;
        end
        default: begin
            RegWrite_o = 0;
            MemWrite_o = 0;
            IRWrite_o = 1;
            AdrSrc_o = 0;
            ALUSrcA_o = 0;
            ALUSrcB_o = 0;
            ResultSrc_o = 2'b00;
        end
    endcase
end

endmodule

endmodule
