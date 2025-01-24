library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_8x16 is
    Port (
        clk    : in  std_logic;
        we     : in  std_logic;
        addr   : in  std_logic_vector(3 downto 0);
        din    : in  std_logic_vector(7 downto 0);
        dout   : out std_logic_vector(7 downto 0)
    );
end RAM_8x16;

architecture Behavioral of RAM_8x16 is
    type ram_type is array (0 to 15) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => x"FF");

begin
    dout <= ram(to_integer(unsigned(addr)));

    ram(to_integer(unsigned(addr))) <= din when we = '1' and rising_edge(clk);

end Behavioral;
