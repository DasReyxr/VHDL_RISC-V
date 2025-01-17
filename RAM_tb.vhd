library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_8x16_tb is
end RAM_8x16_tb;

architecture Behavioral of RAM_8x16_tb is
    -- Component declaration of the RAM entity
    component RAM_8x16
        Port (
            clk    : in  std_logic;
            we     : in  std_logic;
            addr   : in  std_logic_vector(3 downto 0);
            din    : in  std_logic_vector(7 downto 0);
            dout   : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals to connect to the RAM instance
    signal clk   : std_logic := '0';
    signal we    : std_logic := '0';
    signal addr  : std_logic_vector(3 downto 0) := (others => '0');
    signal din   : std_logic_vector(7 downto 0) := (others => '0');
    signal dout  : std_logic_vector(7 downto 0);

begin
    -- Instantiate the RAM
    uut: RAM_8x16
        port map (
            clk   => clk,
            we    => we,
            addr  => addr,
            din   => din,
            dout  => dout
        );

    -- Clock generation
    clock_process: process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Initialize signals
        we <= '0';
        addr <= (others => '0');
        din <= (others => '0');
        wait for 20 ns;

        -- Write data to address 0
        addr <= "0000";
        din <= "10101010";  -- Data to write
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 10 ns; -- Small delay to ensure write completes

        -- Write data to address 1
        addr <= "0001";
        din <= "11001100";
        we <= '1';
        wait for 20 ns;
        we <= '0';
        wait for 10 ns; -- Small delay to ensure write completes

        -- Read from address 0
        addr <= "0000";
        wait for 20 ns;

        -- Read from address 1
        addr <= "0001";
        wait for 20 ns;

        -- Finish simulation
        wait;
    end process;

end Behavioral;
