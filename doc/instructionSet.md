# Instruction Set of RISCV

## Notation and Definitions:

A represents the Accumulator.
Rs denotes Register "s" The opcode format follows "XXXX XRRR", where X represents the instruction opcode, and RRR specifies the register. The system supports a maximum of seven registers.
C, N, Z, V are flag indicators.
M refers to memory.
X, SP are pointer registers, with SP representing the Stack Pointer and X serving as a RAM pointer.
K is a constant. Loading a constant requires two execution cycles: the first cycle executes MOV A, K (opcode x"57"), while the second cycle executes the intended instruction.

## Instructions with Registers

ADC A,Rs |0x"00" - 0x"07"
SBC A,Rs |0x"08" - 0x"0F"
CPC A,Rs |0x"10" - 0x"17"
AND A,Rs |0x"18" - 0x"1F"
ORL A,Rs |0x"20" - 0x"27"
EOR A,Rs |0x"28" - 0x"2F"
MOV A,Rs |0x"30" - 0x"37"
MOV Rs,A |0x"38" - 0x"3F"

## Accumulator Instructions
COM A    |0x"40"
NEG A    |0x"41"
INC A    |0x"42"
DEC A    |0x"43"
CLR A    |0x"44"
ROL A    |0x"45"
ROR A    |0x"46"
## Flags Instructions

SET C    |0x"47"
CLR C    |0x"48"
SET N    |0x"49"
CLR N    |0x"4A"
SET Z    |0x"4B"
CLR Z    |0x"4C"
SET V    |0x"4D"
CLR V    |0x"4E"

MOV A,PO |0x"4F"
MOV P1,A |0x"50"
MOV A,X  |0x"51"
MOV X,A  |0x"52"
MOV A,M  |0x"53"
MOV M,A  |0x"54"
## Stack Pointer Opp
POP A    |0x"55"
PUSH A   |0x"56"
MOV A,K  |0x"57"
INC X    |0x"58"
DEC X    |0x"59"
JMP      |0x"5A"
CALL     |0x"5B"
RET      |0x"5C"
BREQ     |0x"5D"
BRCS     |0x"5E"
BRMI     |0x"5F"
BRVS     |0x"60"
MOV SP,A |0x"61"
NOP      |0x"FF"