// ucsbece154a_controller.v
// All Rights Reserved
// Copyright (c) 2023 UCSB ECE
// Distribution Prohibited

module ucsbece154a_controller (
    input               clk, reset,
    input         [6:0] op_i, 
    input         [2:0] funct3_i,
    input               funct7_i,
    input               zero_i,
    output wire         PCWrite_o,
    output reg          MemWrite_o,    
    output reg          IRWrite_o,
    output reg          RegWrite_o,
    output reg    [1:0] ALUSrcA_o,
    output reg          AdrSrc_o,
    output reg    [1:0] ResultSrc_o,
    output reg    [1:0] ALUSrcB_o,
    output reg    [2:0] ALUControl_o,
    output reg    [2:0] ImmSrc_o
);

 `include "ucsbece154a_defines.vh"

// **********   Immediate Source Selection (ImmSrc_o)  *********
always @ * begin
   case (op_i)
        instr_lw_op:        ImmSrc_o = 3'b000;       // Load instruction
        instr_sw_op:        ImmSrc_o = 3'b001;       // Store instruction
        instr_Rtype_op:     ImmSrc_o = 3'bxxx;       // R-type: No immediate value
        instr_beq_op:       ImmSrc_o = 3'b010;       // Branch instruction (BEQ)
        instr_ItypeALU_op:  ImmSrc_o = 3'b000;       // Immediate ALU (Add, Sub, etc.)
        instr_jal_op:       ImmSrc_o = 3'b011;       // JAL instruction
        instr_lui_op:       ImmSrc_o = 3'b100;       // LUI (Load Upper Immediate)
        default:            ImmSrc_o = 3'bxxx;       // Default case: Invalid
   endcase
end

// ********** ALU Control Logic *********
reg  [1:0] ALUOp;    // ALU Operation (ADD, SUB, SLT, etc.)
wire RtypeSub = funct7_i & op_i[5];  // Detects subtraction for R-type instructions

always @ * begin
    case(ALUOp)
       ALUop_mem:           ALUControl_o = ALUcontrol_add;   // Memory-related operations (Add)
       ALUop_beq:           ALUControl_o = ALUcontrol_sub;   // Branch equal (BEQ)
       ALUop_other: 
         case(funct3_i) 
           instr_addsub_funct3: 
               ALUControl_o = (RtypeSub) ? ALUcontrol_sub : ALUcontrol_add;  // Handle ADD/SUB for R-type
           instr_slt_funct3:    ALUControl_o = ALUcontrol_slt;  // Set Less Than
           instr_or_funct3:     ALUControl_o = ALUcontrol_or;   // OR operation
           instr_and_funct3:    ALUControl_o = ALUcontrol_and;  // AND operation
           default:             ALUControl_o = 3'bxxx;   // Default: Invalid instruction
         endcase
    default:               ALUControl_o = 3'bxxx;   // Default: Invalid ALUOp
    endcase
end

// ********** PC Write Logic *********
reg Branch, PCUpdate;  // Flags for controlling PC write

assign PCWrite_o = (Branch & zero_i) | PCUpdate;  // PC is written based on Branch condition or update signal

// ********** FSM State Transitions *********
reg [3:0] state;    // FSM current state
reg [3:0] state_next;  // FSM next state

// State machine for FSM state transitions
always @ * begin
    if (reset) begin
        state_next = 4'bzzzz;   // Reset state
    end else begin             
        case (state)
            state_Fetch:           state_next = 4'bzzzz;  // Fetch state transition
            state_Decode: begin
                case (op_i)
                    instr_lw_op:       state_next = 4'bzzzz;  
                    instr_sw_op:       state_next = 4'bzzzz;  
                    instr_Rtype_op:    state_next = 4'bzzzz;  
                    instr_beq_op:      state_next = 4'bzzzz;  
                    instr_ItypeALU_op: state_next = 4'bzzzz;  
                    instr_lui_op:      state_next = 4'bzzzz;  
                    instr_jal_op:      state_next = 4'bzzzz;  
                    default:           state_next = 4'bxxxx;
                endcase
            end
            state_MemAdr: begin 
                case (op_i)
                    instr_lw_op:       state_next = 4'bzzzz;  
                    instr_sw_op:       state_next = 4'bzzzz;  
                    default:           state_next = 4'bxxxx;
                endcase
            end
            default:               state_next = 4'bxxxx;
        endcase
    end
end

// ********** Control Signal Generation *********
reg [13:0] controls_next;  // Next value for control signals

// Assign next control signals
wire       PCUpdate_next, Branch_next, MemWrite_next, IRWrite_next, RegWrite_next, AdrSrc_next;
wire [1:0] ALUSrcA_next, ALUSrcB_next, ResultSrc_next, ALUOp_next;

assign {
    PCUpdate_next, Branch_next, MemWrite_next, IRWrite_next, RegWrite_next,
    ALUSrcA_next, ALUSrcB_next, AdrSrc_next, ResultSrc_next, ALUOp_next
} = controls_next;

// Control signal logic for each state
always @ * begin
    case (

end

endmodule
