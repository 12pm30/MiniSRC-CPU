library ieee;
use ieee.std_logic_1164.all;

entity ConFF_3Bus is
port(	ir_in : in std_logic_vector(1 downto 0);
		r_in : in std_logic_vector(31 downto 0);
		result: out std_logic);
end entity;

architecture swag of ConFF_3Bus is

begin

result <= 	'1' when ir_in = "00" AND r_in = x"00000000" else
				'1' when ir_in = "01" AND r_in /= x"00000000" else
				'1' when ir_in = "10" AND r_in(31) = '0' else
				'1' when ir_in = "11" AND r_in(31) = '1' else
				'0';
				
end architecture;