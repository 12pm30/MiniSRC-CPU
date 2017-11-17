library IEEE;
use IEEE.std_logic_1164.all; 

entity MemDataReg is
port( 	BusMuxOut, MDataIn : in std_logic_vector(31 downto 0);
			read_sel, clear, clk, mdr_en : in std_logic;
			MDR_out : out std_logic_vector(31 downto 0) := x"00000000");
end entity MemDataReg;


architecture jesus of MemDataReg is

component reg32 is
	port (input : in std_logic_vector(31 downto 0);
			output : out std_logic_vector(31 downto 0);
			en, clk, reset : in std_logic);
end component;

signal mem_temp : std_logic_vector(31 downto 0);

begin

mem_temp <= BusMuxOut when read_sel = '0' else MDataIn;
	
TheDataRegCrap : process(mem_temp,mdr_en,clear)
begin

		if clear = '1' then
			MDR_out <= x"00000000";
		elsif mdr_en = '1' then
			MDR_out <= mem_temp;
		end if;
end process;

--	MemReg : reg32 port map(
	--		 input => mem_temp,
		--	 output => MDR_out,
			-- en => mdr_en,
			 --clk => clk,
			 --reset => clear
			 --);
			 
end architecture;
			