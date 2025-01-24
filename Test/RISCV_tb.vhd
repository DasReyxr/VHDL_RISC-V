----------- Testbench -----------
--------- Auf Das ---------
------ RISCV ------
-------- 03/01/2025 --------
------- Main Library -------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb is
end tb;

architecture sim of tb is

component RISCV
	PORT(
        ---- Main Clock ---
        RESETV, CLK : in std_logic;
        -- Rom & Ram --
        --ROMIN: in std_logic_vector (7 downto 0);
        RAMIN : inout std_logic_vector (7 downto 0);
        -- Address --
        PCIN, ADDRESSRAM: out std_logic_vector (7 downto 0);
        WRAM : out std_logic;
        -- Ports --
        P0IN : in  std_logic_vector (7 downto 0);
        P1OUT: out std_logic_vector (7 downto 0);
        P_DEBUG : out std_logic_vector (7 downto 0)
        );
end component;
signal S_RESET, S_CLK :  std_logic:= '1';
signal S_PCIN, S_ADDRESSRAM:  std_logic_vector (7 downto 0);
signal S_WRAM :  std_logic;
signal S_RAMIN : std_logic_vector(7 downto 0);
-- Ports --
signal S_P0IN :   std_logic_vector (7 downto 0);
signal S_P1OUT:  std_logic_vector (7 downto 0);
signal S_P_DEBUG :  std_logic_vector (7 downto 0);

begin
	uut: RISCV port map(S_RESET,S_CLK,S_RAMIN,S_PCIN,S_ADDRESSRAM,S_WRAM,S_P0IN,S_P1OUT,S_P_DEBUG);

	process
	begin
        S_Clk <= '0';
        wait for 18.5 ns;	
        S_Clk <= '1';
        wait for 18.5 ns;
	end process;
end sim;