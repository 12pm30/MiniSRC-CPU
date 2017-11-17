Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity PotatoALU_tb is
end entity;

architecture yoloswag of PotatoALU_tb is

COMPONENT PotatoALU
	PORT
	(
		a_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		b_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		c_low_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		c_hi_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		clk		:	 IN STD_LOGIC;
		carry_in		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		fcn_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		overflow_out		:	 OUT STD_LOGIC;
		underflow_out		:	 OUT STD_LOGIC;
		carry_out		:	 OUT STD_LOGIC
	);
END COMPONENT;

signal a, b, c_hi, c_low : std_logic_vector(31 downto 0);
signal fsel : std_logic_vector(4 downto 0);

signal clk, rst, cout, cin, ofout, ufout : std_logic;

begin


Aloo : PotatoALU port map (
	a_in => a,
	b_in => b,
	c_low_out => c_low,
	c_hi_out => c_hi,
	clk => clk,
	carry_in => cin,
	reset => rst,
	fcn_sel => fsel,
	overflow_out => ofout,
	underflow_out => ufout,
	carry_out => cout
);

a <= conv_std_logic_vector(2659,32);
b <= conv_std_logic_vector(3,32);
clk <= '0';
cin <= '0';
rst <= '0';
fsel <= "10010";


end architecture;