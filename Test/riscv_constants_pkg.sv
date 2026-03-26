package riscv_constants_pkg;

    localparam [2:0] M_ALU   = 3'd0 ;
    localparam [2:0] M_ROMIN = 3'd1 ;
    localparam [2:0] M_PCIN  = 3'd2 ;
    localparam [2:0] M_RAMIN = 3'd3 ;
    localparam [2:0] M_XIN   = 3'd4 ;
    localparam [2:0] M_SPIN  = 3'd5 ;
    localparam [2:0] M_P0IN  = 3'd6 ;
    localparam [2:0] M_INA   = 3'd7 ;

    localparam [7:0] INST_ADC_L = 8'h00;
    localparam [7:0] INST_ADC_H = 8'h07;
    localparam [7:0] INST_SBC_L = 8'h08;
    localparam [7:0] INST_SBC_H = 8'h0F;

    localparam [7:0] INST_CPC_L = 8'h10;
    localparam [7:0] INST_CPC_H = 8'h17;

    localparam [7:0] INST_AND_L = 8'h18;
    localparam [7:0] INST_AND_H = 8'h1F;

    localparam [7:0] INST_ORL_L = 8'h20;
    localparam [7:0] INST_ORL_H = 8'h27;

    localparam [7:0] INST_EOR_L = 8'h28;
    localparam [7:0] INST_EOR_H = 8'h2F;


    localparam [7:0] INST_MOV_L = 8'h30;
    localparam [7:0] INST_MOV_H = 8'h3F;

    localparam [7:0] INST_COM = 8'h40;
    localparam [7:0] INST_NEG = 8'h41;
    localparam [7:0] INST_INC = 8'h42;
    localparam [7:0] INST_DEC = 8'h43;
    localparam [7:0] INST_CLR = 8'h44;
    localparam [7:0] INST_ROL = 8'h45;
    localparam [7:0] INST_ROR = 8'h46;
    localparam [7:0] INST_SET_C = 8'h47;
    localparam [7:0] INST_CLR_C = 8'h48;
    localparam [7:0] INST_SET_N = 8'h49;
    localparam [7:0] INST_CLR_N = 8'h4A;
    localparam [7:0] INST_SET_Z = 8'h4B;
    localparam [7:0] INST_CLR_Z = 8'h4C;
    localparam [7:0] INST_SET_V = 8'h4D;
    localparam [7:0] INST_CLR_V = 8'h4E;
    localparam [7:0] INST_MOV_P0 = 8'h4F;
    localparam [7:0] INST_MOV_P1 = 8'h50;
    localparam [7:0] INST_MOV_X  = 8'h51;
    localparam [7:0] INST_MOV_A  = 8'h52;
    localparam [7:0] INST_MOV_M  = 8'h53;
    localparam [7:0] INST_MOV_M  = 8'h54;
    localparam [7:0] INST_POP = 8'h55;
    localparam [7:0] INST_PUSH = 8'h56;
    localparam [7:0] INST_MOV_K  = 8'h57;
    localparam [7:0] INST_INC_X = 8'h58;
    localparam [7:0] INST_DEC_X = 8'h59;
    localparam [7:0] INST_JMP = 8'h5A;
    localparam [7:0] INST_CALL = 8'h5B;
    localparam [7:0] INST_RET = 8'h5C;
    localparam [7:0] INST_BREQ = 8'h5D;
    localparam [7:0] INST_BRCS = 8'h5E;
    localparam [7:0] INST_BRMI = 8'h5F;
    localparam [7:0] INST_BRVS = 8'h60;
    localparam [7:0] INST_MOV_SP = 8'h61;
    localparam [7:0] INST_NOP = 8'hFF;



    localparam int ROM_DEPTH = 36;
    localparam logic [7:0] ROM_DEFAULT = 8'hFF;

    localparam logic [7:0] ROM_INIT [0:ROM_DEPTH-1] = '{
        INST_MOV_K, 8'h01, INST_MOV_P1, INST_ROL,
        INST_MOV_P1, INST_ROL, INST_MOV_P1, INST_ROL,
        INST_MOV_P1, INST_ROL, INST_MOV_P1, INST_ROL,
        INST_MOV_P1, INST_ROL, INST_MOV_P1, INST_ROL,
        INST_MOV_P1, INST_ROR, INST_MOV_P1, INST_ROR,
        INST_MOV_P1, INST_ROR, INST_MOV_P1, INST_ROR,
        INST_MOV_P1, INST_ROR, INST_MOV_P1, INST_ROR,
        INST_MOV_P1, INST_ROR, INST_MOV_P1, INST_ROR,
        INST_MOV_P1, INST_ROR, INST_MOV_P1, INST_CLR
    };

endpackage


