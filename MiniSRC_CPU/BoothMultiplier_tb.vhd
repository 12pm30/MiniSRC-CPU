Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity BoothMultiplier_tb is
end entity;

architecture testbench of boothMultiplier_tb is

function tc_neg (input : std_logic_vector)
	return std_logic_vector is
begin
	return (unsigned(NOT input) + '1');
end;
	
function sgn_xtnd (input : std_logic_vector(31 downto 0))
	return std_logic_vector is
	variable tmp : std_logic_vector(63 downto 0);
begin
	tmp(31 downto 0) := input;

	if input(31) = '1' then
		tmp(63 downto 32) := "11111111111111111111111111111111";
	else
		tmp(63 downto 32) := "00000000000000000000000000000000";
	end if;
	
	return tmp;
end;


COMPONENT BoothMultiplier
	PORT
	(
		m_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		q_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		result_out		:	 OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		n_out, t_z_out, t_o_out : out STD_LOGIC_VECTOR(15 downto 0);
		done		:	 OUT STD_LOGIC
	);
END COMPONENT;

signal m,q : std_LOGIC_VECTOR(31 downto 0);
signal result : std_LOGIC_VECTOR(63 downto 0);
signal n, t_o, t_z : std_LOGIC_VECTOR(15 downto 0);
signal start : std_LOGIC := '1';
signal done : std_logic;
begin

m <= conv_std_logic_vector(-1001,32);
q <= conv_std_logic_vector(711,32);


BoothTest : BoothMultiplier port map(
				m_in => m,
				q_in => q,
				result_out => result,
				done => done,
				n_out => n,
				t_z_out => t_z,
				t_o_out => t_o
				);
				
			
end architecture;