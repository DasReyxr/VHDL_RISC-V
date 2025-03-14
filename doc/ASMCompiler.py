"""
------ Orlando Reyes ------
--------- Auf Das ---------
------- ASM Compiler -------
-------- 14/03/2025 --------
"""
# ------- Main Library -------
# --------- Function ---------
# ---------- Class ----------
# -------- Variables --------

PATH = r"C:\Users\Das\Dropbox\Obsidian\Fisica\tmp\VHDL_RISC-V\doc\instructions.s"
assembler_map = {
    "COMA": "40",
    "NEGA": "41",
    "INCA": "42",
    "DECA": "43",
    "CLRA": "44",
    "ROLA": "45",
    "RORA": "46",
    "SETC": "47",
    "CLRC": "48",
    "SETN": "49",
    "CLRN": "4A",
    "SETZ": "4B",
    "CLRZ": "4C",
    "SETV": "4D",
    "CLRV": "4E",
    "MOVA,PO": "4F",
    "MOVP1,A": "50",
    "MOVA,X": "51",
    "MOVX,A": "52",
    "MOVA,M": "53",
    "MOVM,A": "54",
    "POPA": "55",
    "PUSHA": "56",
    "MOVA,K": "57",
    "INCX": "58",
    "DECX": "59",
    "JMP": "5A",
    "CALL": "5B",
    "RET": "5C",
    "BREQ": "5D",
    "BRCS": "5E",
    "BRMI": "5F",
    "BRVS": "60",
    "MOVSP,A": "61",
    "NOP": "FF",
}


# ----------- Main -----------

def main ():
    iterative = 0  

    with open(PATH, "r") as file:
        for line in file:
            assembly_instr = line.replace(" ","").strip().upper() # Unformat the text
            #print(assembly_instr)
            opcode = assembler_map.get(assembly_instr, "JUAN")
            if opcode == "JUAN":            
                return
            print(f'x"{opcode}", ', end="")

            iterative += 1

            # Add a new line after every 4th instruction
            if iterative == 4:
                print() 
                iterative = 0 
main()