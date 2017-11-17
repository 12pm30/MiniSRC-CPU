--IR Decoding Magic
--gAxx - selects the register as specified in the instruction, sticks it on the A bus
--gBxx - selects the register as specified in the instruction, sticks it on the A bus
--BAout might be irrelevant here- since we're doing 3 buses?

library ieee;
use ieee.std_logic_1164.all;

entity SelectDecode_3bus is
port(	ir_in : in std_logic_vector(31 downto 0);
		c_sx : out std_logic_vector(31 downto 0);
		rIN : in std_logic;
		gAra, gArb, gArc : in std_logic;
		gBra, gBrb, gBrc : in std_logic;
		a_sel_out, b_sel_out : out std_logic_vector(3 downto 0);
		c_r0, c_r1, c_r2, c_r3, c_r4, c_r5, c_r6, c_r7, c_r8, c_r9, c_r10, c_r11, c_r12, c_r13, c_r14, c_r15 : out std_logic
		);
end entity;

architecture swag of SelectDecode_3bus is

begin

--c_sign_extended
c_sx(17 downto 0) <= ir_in(17 downto 0);
c_sx(31 downto 18) <= (others => '1') when ir_in(18) = '1' else (others => '0');

--a and b bus selections from register file
a_sel_out <= ir_in(26 downto 23) when gAra = '1' else  ir_in(22 downto 19) when gArb = '1' else ir_in(18 downto 15) when gArc = '1' else "0000";
b_sel_out <= ir_in(26 downto 23) when gBra = '1' else  ir_in(22 downto 19) when gBrb = '1' else ir_in(18 downto 15) when gBrc = '1' else "0000";

--register input selection from C bus
c_r0 <= rIN when ir_in(26 downto 23) = "0000" else '0';
c_r1 <= rIN when ir_in(26 downto 23) = "0001" else '0';
c_r2 <= rIN when ir_in(26 downto 23) = "0010" else '0';
c_r3 <= rIN when ir_in(26 downto 23) = "0011" else '0';
c_r4 <= rIN when ir_in(26 downto 23) = "0100" else '0';
c_r5 <= rIN when ir_in(26 downto 23) = "0101" else '0';
c_r6 <= rIN when ir_in(26 downto 23) = "0110" else '0';
c_r7 <= rIN when ir_in(26 downto 23) = "0111" else '0';
c_r8 <= rIN when ir_in(26 downto 23) = "1000" else '0';
c_r9 <= rIN when ir_in(26 downto 23) = "1001" else '0';
c_r10 <= rIN when ir_in(26 downto 23) = "1010" else '0';
c_r11 <= rIN when ir_in(26 downto 23) = "1011" else '0';
c_r12 <= rIN when ir_in(26 downto 23) = "1100" else '0';
c_r13 <= rIN when ir_in(26 downto 23) = "1101" else '0';
c_r14 <= rIN when ir_in(26 downto 23) = "1110" else '0';
c_r15 <= rIN when ir_in(26 downto 23) = "1111" else '0';

end architecture;