library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb is
-- Testbench has no ports
end tb;

architecture sim of tb is
    -- Component declaration for the Unit Under Test (UUT)
    component rom_example
        Port (
            address : in std_logic_vector(3 downto 0); -- 4-bit address
            data_out : out std_logic_vector(7 downto 0) -- 8-bit output
        );
    end component;

    -- Signals to connect to UUT
    signal address : std_logic_vector(3 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: rom_example
        Port map (
            address => address,
            data_out => data_out
        );

    -- Test process
    process
    begin
        -- Test address 0
        address <= "0000"; wait for 10 ns;
        -- Test address 1
        address <= "0001"; wait for 10 ns;
        -- Test address 2
        address <= "0010"; wait for 10 ns;
        -- Test address 3
        address <= "0011"; wait for 10 ns;
        -- Test address 4
        address <= "0100"; wait for 10 ns;
        -- Test address 8
        address <= "1000"; wait for 10 ns;
        -- Test address 15
        address <= "1111"; wait for 10 ns;
        -- Finish simulation
        wait;
    end process;
end sim;
