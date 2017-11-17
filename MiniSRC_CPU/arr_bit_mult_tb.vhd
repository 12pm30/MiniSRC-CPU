library ieee;
use ieee.std_logic_1164.all;

entity arr_bit_mult_tb is

port ( p_led : out std_LOGIC_VECTOR(7 downto 0));

end entity;

architecture fucked of arr_bit_mult_tb is


COMPONENT arr_bit_mult
	PORT
	(
		m_in		:	 IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		q_in		:	 IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		p_out		:	 OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;



signal m, q : std_LOGIC_VECTOR(7 downto 0);
signal p : std_LOGIC_VECTOR(15 downto 0);

begin

	m <= "00001111";
	q <= "00000010";

	TestMult : arr_bit_mult port map(
			m_in => m,
			q_in => q,
			p_out => p 
			);

	p_led <= p(7 downto 0) after 5ns;

end architecture;