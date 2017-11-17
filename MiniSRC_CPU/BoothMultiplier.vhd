library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity BoothMultiplier is
	port ( m_in,q_in : in std_logic_vector(31 downto 0);
			 n_out, t_o_out, t_z_out : out std_logic_vector(15 downto 0);
			result_out : out std_logic_vector(63 downto 0);
			done : out std_logic);
end entity;


architecture operation of BoothMultiplier is
	
function negate (input : std_logic_vector)
	return std_logic_vector is
begin
	return ((NOT input) + '1');
end;

function positive_one (input : std_logic_vector(31 downto 0)) return std_logic_vector is
variable tmp : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
begin

	tmp(31 downto 0) := input;
	
	if input(31) = '1' then
		tmp(63 downto 32) := "11111111111111111111111111111111";
	end if;
	
	return tmp;

end;

function negative_one (input : std_logic_vector(31 downto 0)) return std_logic_vector is
begin

return negate(positive_one(input));

end;

function positive_two (input : std_logic_vector(31 downto 0)) return std_logic_vector is
variable tmp : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
begin

	if input(31) = '1' then
		tmp(31 downto 0) := negate(input);
	else
		tmp(31 downto 0) := input;
	end if;
	
	tmp := shl(tmp,"1");
	
	if input(31) = '1' then
		tmp := negate(tmp);
	end if;
	
	return tmp;
end;


	
function negative_two (input : std_logic_vector(31 downto 0))
	return std_logic_vector is
variable tmp : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
begin

	if input(31) = '1' then
		tmp(31 downto 0) := negate(input);
	else
		tmp(31 downto 0) := input;
	end if;
	
	tmp := shl(tmp,"1");
	
	if input(31) = '0' then
		tmp := negate(tmp);
	end if;
	
	return tmp;
end;


begin

swag : process(m_in,q_in)


variable t_o, t_z, n : std_logic_vector(15 downto 0) := "0000000000000000";
variable m_in_tmp : std_logic_vector(31 downto 0);
variable result : std_logic_vector(63 downto 0);
variable m_tmp : std_logic_vector(63 downto 0);
begin
			done <= '0';
			
			m_in_tmp := m_in;
			result  := "0000000000000000000000000000000000000000000000000000000000000000";
			m_tmp := "0000000000000000000000000000000000000000000000000000000000000000";
			
			
			n(0) := q_in(1);
			t_z(0)  := q_in(0);
			t_o(0)  := q_in(1) AND NOT q_in(0);
			
			for cycle in 1 to 15 loop
			
			n(cycle) := q_in((2*cycle) + 1);
			t_z(cycle) := q_in((2*cycle)) XOR q_in((2*cycle) - 1);
			t_o(cycle) := (q_in((2*cycle) + 1) AND NOT q_in((2*cycle)) AND NOT q_in((2*cycle) - 1)) OR (NOT q_in((2*cycle) + 1) AND q_in((2*cycle)) AND q_in((2*cycle) - 1));
			
			end loop;
			
			n_out <= n;
			t_z_out <= t_z;
			t_o_out <= t_o;
			
			for cycle in 0 to 15 loop
				
				if t_z(cycle) = '1' or t_o(cycle) = '1' then
				
					if t_o(cycle) = '1' then
						if n(cycle) = '1' then
							m_tmp := negative_two(m_in_tmp);
						else
							m_tmp := positive_two(m_in_tmp);
						end if;
					elsif t_z(cycle) = '1' then
						if n(cycle) = '1' then
							m_tmp := negative_one(m_in_tmp);
						else
							m_tmp := positive_one(m_in_tmp);
						end if;
					end if;
				
				m_tmp := shl(m_tmp,conv_std_logic_vector(2 * cycle,32));
				
				result := result + m_tmp;
				
				end if;
					
			end loop;
			
			result_out <= result;
			
			done <= '1';
			
end process;


end architecture;


	
	
	
	
	