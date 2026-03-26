// ----------- Code -----------
// --------- Auf Das ---------
// ----------- MIPS -----------
// --- I. Date: 03/23/2026 ---
// ------- Main Library -------

module MIPS (
    input  wire CLK,
    input  wire Reset,
    output reg  [31:0] PC
);

localparam [5:0] F_ADD     = 6'b100000;
localparam [5:0] F_ADDU    = 6'b100001;
localparam [5:0] F_SUB     = 6'b100010;
localparam [5:0] F_SUBU    = 6'b100011;
localparam [5:0] F_MULT    = 6'b011000;
localparam [5:0] F_MULTU   = 6'b011001;
localparam [5:0] F_DIV     = 6'b011010;
localparam [5:0] F_DIVU    = 6'b011011;
localparam [5:0] F_AND     = 6'b100100;
localparam [5:0] F_OR      = 6'b100101;
localparam [5:0] F_XOR     = 6'b100110;
localparam [5:0] F_JR      = 6'b001000;
localparam [5:0] F_SLT     = 6'b101010;
localparam [5:0] F_SLTU    = 6'b101011;
localparam [5:0] F_SLL     = 6'b000000;
localparam [5:0] F_SRL     = 6'b000010;
localparam [5:0] F_SRA     = 6'b000011;
localparam [5:0] F_SLLV    = 6'b000100;
localparam [5:0] F_SRLV    = 6'b000110;
localparam [5:0] F_SRAV    = 6'b000111;
localparam [5:0] F_NOP     = 6'b000000;
localparam [5:0] F_SYSCALL = 6'b001100;
localparam [5:0] F_BREAK   = 6'b001101;

localparam [5:0] I_RTYPE = 6'b000000;
localparam [5:0] I_BEQ   = 6'b000100;
localparam [5:0] I_BNE   = 6'b000101;
localparam [5:0] I_J     = 6'b000010;
localparam [5:0] I_JAL   = 6'b000011;
localparam [5:0] I_LB    = 6'b100000;
localparam [5:0] I_LW    = 6'b100011;
localparam [5:0] I_SB    = 6'b101000;
localparam [5:0] I_SW    = 6'b101011;
localparam [5:0] I_ADDI  = 6'b001000;

localparam [2:0] TYPE_R = 3'b001;
localparam [2:0] TYPE_I = 3'b010;
localparam [2:0] TYPE_J = 3'b100;

reg CNT_regDst   = 1'b0;
reg CNT_Jump     = 1'b0;
reg CNT_Bra      = 1'b0;
reg CNT_aluSrc   = 1'b0;
reg CNT_ALUOp    = 1'b0;
reg CNT_memRead  = 1'b0;
reg CNT_memWrite = 1'b0;
reg CNT_regWrite = 1'b0;

reg [2:0]  TYPE_INST = 3'b000; // 001=R, 010=I, 100=J
reg [5:0]  OPCODE;
reg [25:0] ADDR;
reg [15:0] Imm;
reg [4:0]  rs;
reg [4:0]  rt;
reg [4:0]  rd;
reg [5:0]  funct;

reg        Branch;
reg        Jump;
reg        MemRead;
reg        MemWrite;
reg        Mem2Reg;
reg        RegWrite;
reg        ALUSrc;
reg        RegDst;
reg        F_ZERO;

// Instruction placeholder until memory/fetch is connected.
reg [31:0] ROMIN;

always_ff @(posedge CLK or posedge Reset) begin
    if (Reset)
        PC <= 32'd0;
    else
        PC <= PC + 32'd4;
end

// ---------- Decoder ----------
always_comb begin
    OPCODE = ROMIN[31:26];

    if (ROMIN[31:26] == 6'b000000)
        TYPE_INST = TYPE_R;
    else if (ROMIN[31:27] == 5'b00001)
        TYPE_INST = TYPE_J;
    else
        TYPE_INST = TYPE_I;

    if (TYPE_INST != TYPE_J) begin
        rs = ROMIN[25:21];
        rt = ROMIN[20:16];
    end else begin
        rs = 5'd0;
        rt = 5'd0;
    end

    if (TYPE_INST == TYPE_R) begin
        rd    = ROMIN[15:11];
        funct = ROMIN[5:0];
    end else begin
        rd    = 5'd0;
        funct = 6'd0;
    end

    if (TYPE_INST == TYPE_I)
        Imm = ROMIN[15:0];
    else
        Imm = 16'd0;

    if (TYPE_INST == TYPE_J)
        ADDR = ROMIN[25:0];
    else
        ADDR = 26'd0;
end

// Control Signals
always_comb begin
    CNT_Branch   = ((OPCODE == I_BEQ) && (F_ZERO == 1'b1)) || ((OPCODE == I_BNE) && (F_ZERO == 1'b0));
    CNT_Jump     = (OPCODE == I_J) || (OPCODE == I_JAL);
    CNT_MemRead  = (OPCODE == I_LB) || (OPCODE == I_LW);
    CNT_MemWrite = (OPCODE == I_SB) || (OPCODE == I_SW);
    CNT_Mem2Reg  = (OPCODE == I_LB) || (OPCODE == I_LW);
    CNT_RegWrite = (OPCODE == I_ADDI) || (OPCODE == I_LB) || (OPCODE == I_LW);
    CNT_ALUSrc   = (TYPE_INST == TYPE_I);
    CNT_RegDst   = (OPCODE == I_RTYPE);
end


always_comb begin
    ROMIN  = 32'd0;
    F_ZERO = 1'b0;
end

endmodule