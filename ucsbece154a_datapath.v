// ucsbece154a_datapath.v
// All Rights Reserved
// Copyright (c) 2023 UCSB ECE
// Distribution Prohibited

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// TO DO: Add missing code below  
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module ucsbece154a_datapath (
    input clk, reset,
    input [6:0] op_i, 
    input [2:0] funct3_i,
    input funct7_i,
    input zero_i,
    input [31:0] imm_i,        // Immediate input
    input [31:0] ALU_result_i, // ALU result
    input [31:0] read_data_i,  // Data from memory (for load)
    output [31:0] ALU_A_o,     // ALU input A
    output [31:0] ALU_B_o,     // ALU input B
    output [31:0] result_o,    // Result (either from ALU or memory)
    output [31:0] PC_o,        // Program counter output
    output [31:0] MemAddr_o,   // Memory address output
    output MemWrite_o,         // Memory write enable
    output IRWrite_o,          // Instruction register write enable
    output RegWrite_o,         // Register write enable
    output PCWrite_o           // Program counter write enable
);

    // Registers
    reg [31:0] PC;             // Program counter
    reg [31:0] IR;             // Instruction register
    reg [31:0] RegFile [31:0]; // Register file

    // MUXes for selecting ALU inputs
    assign ALU_A_o = RegFile[IR[19:15]];       // rs1
    assign ALU_B_o = (ALUSrcB_o) ? imm_i : RegFile[IR[24:20]]; // rs2 or imm

    // ALU operation
    wire [31:0] ALU_result;
    ALU alu(.A(ALU_A_o), .B(ALU_B_o), .ALUOp(ALUControl_o), .result(ALU_result));

    // Memory operation
    assign MemAddr_o = ALU_result;       // Address from ALU result
    assign MemWrite_o = MemWrite_o;      // From controller

    // Write back to register file
    assign result_o = (ResultSrc_o == 2'b00) ? ALU_result : read_data_i;

    // Program counter control
    assign PCWrite_o = (Branch_o && zero_i) || (PCUpdate); // PCWrite signal

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'h0;
            IR <= 32'h0;
        end else begin
            if (IRWrite_o)
                IR <= read_data_i; // Load instruction into IR
            if (PCWrite_o)
                PC <= result_o;  // Update program counter
            if (RegWrite_o)
                RegFile[IR[11:7]] <= result_o; // Write result to register file
        end
    end
endmodule
