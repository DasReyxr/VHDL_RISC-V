-- my_defs_pkg.vhd
library ieee;
use ieee.std_logic_1164.all;

package my_defs_pkg is

  constant I_ADD: std_logic_vector(5 downto 0)    := "100000";
  constant I_ADDU: std_logic_vector(5 downto 0)   := "100001";
  constant I_SUB: std_logic_vector(5 downto 0)    := "100010";
  constant I_SUBU: std_logic_vector(5 downto 0)   := "100011";
  constant I_MULT: std_logic_vector(5 downto 0)   := "011000";
  constant I_MULTU: std_logic_vector(5 downto 0)  := "011001";
  constant I_DIV: std_logic_vector(5 downto 0)    := "011010";
  constant I_DIVU: std_logic_vector(5 downto 0)   := "011011";
  constant I_AND: std_logic_vector(5 downto 0)    := "100100";
  constant I_OR: std_logic_vector(5 downto 0)     := "100101";
  constant I_XOR: std_logic_vector(5 downto 0)    := "100110";
  constant I_JR: std_logic_vector(5 downto 0)     := "001000";
  constant I_SLT: std_logic_vector(5 downto 0)    := "101010";
  constant I_SLTU: std_logic_vector(5 downto 0)   := "101011";
  constant I_SLL: std_logic_vector(5 downto 0)    := "000000";
  constant I_SRL: std_logic_vector(5 downto 0)    := "000010";
  constant I_SRA: std_logic_vector(5 downto 0)    := "000011";
  constant I_SLLV: std_logic_vector(5 downto 0)   := "000100";
  constant I_SRLV: std_logic_vector(5 downto 0)   := "000110";
  constant I_SRAV: std_logic_vector(5 downto 0)   := "000111";
  constant I_NOP: std_logic_vector(5 downto 0)    := "000000";
  constant I_SYSCALL: std_logic_vector(5 downto 0):= "001100";
  constant I_BREAK: std_logic_vector(5 downto 0)  := "001101";

  constant DATA_WIDTH : natural := 8;
  constant ADDR_WIDTH : natural := 16;
  constant RESET_LEVEL : std_logic := '0';


end package;

package body my_defs_pkg is
  -- only needed if you define functions/procedures
end package body;