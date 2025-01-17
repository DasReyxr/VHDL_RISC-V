library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_example is
    Port (
        address : in std_logic_vector(3 downto 0); -- 4-bit address
        data_out : out std_logic_vector(7 downto 0) -- 8-bit output
    );
end rom_example;

architecture Behavioral of rom_example is
    -- Define a ROM using a constant array
    type  MEMORY is array (0 to 15) of std_logic_vector(7 downto 0);
    constant ROM_CONTENT:MEMORY :=   (
        "00000001", "00000010", "00000011", "00000100", -- Data values for addresses 0 to 3
        "00000101", "00000110", "00000111", "00001000", -- Data values for addresses 4 to 7
        "00001001", "00001010", "00001011", "00001100", -- Data values for addresses 8 to 11
        "00001101", "00001110", "00001111", "00010000"  -- Data values for addresses 12 to 15
    );

begin
    -- Assign data based on address
    data_out <= ROM_CONTENT(to_integer(unsigned(address)));
end Behavioral;
