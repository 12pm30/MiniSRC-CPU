library IEEE;
use IEEE.std_logic_1164.all;


entity reg32_r0 is
port( input : in std_logic_vector(31 downto 0);
		BaseAddr_out : in std_logic;
		output : out std_logic_vector(31 downto 0);
		en, reset, clk : in std_logic);
end entity reg32_r0;

architecture cardgames of reg32_r0 is

signal q_out : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";

begin

	output <= "00000000000000000000000000000000" when BaseAddr_out = '1' else q_out;


	onmotorcycles : process(clk , reset)
	begin
		if reset = '1' then
					q_out <= "00000000000000000000000000000000";
		elsif rising_edge(clk) then
			if en = '1' then
				q_out <= input;
			end if;	
		end if;
	end process;
end architecture;
