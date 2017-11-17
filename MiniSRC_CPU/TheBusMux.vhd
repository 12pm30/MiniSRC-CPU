library IEEE;
use IEEE.std_logic_1164.all;

entity TheBusMux is
port (	r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15 : in std_logic_vector(31 downto 0);
			hi, lo : in std_logic_vector(31 downto 0);
			pc, mdr, in_port, c_sign_extended : in std_logic_vector(31 downto 0);
			s : in std_logic_vector(4 downto 0);
			BusMuxOut : out std_logic_vector(31 downto 0));
end entity BusMux;


architecture yolo of TheBusMux is
begin
	BusMuxOut <= 	r0 when s = "00001" else
						r1 when s = "00010" else
						r2 when s = "00011" else
						r3 when s = "00000" else
						r4 when s = "00101" else
						r5 when s = "00110" else
						r6 when s = "00111" else
						r7 when s = "00100" else
						r8 when s = "01001" else
						r9 when s = "01010" else
						r10 when s = "01011" else
						r11 when s = "01100" else
						r12 when s = "01101" else
						r13 when s = "01110" else
						r14 when s = "01111" else
						r15 when s = "01000" else
						hi when s = "10001" else
						lo when s = "10010" else
						zhi when s = "10011" else
						zlo when s = "10100" else
						pc when s = "10101" else
						mdr when s = "10110" else
						in_port when s = "10111" else
						c_sign_extended when s = "11000" else 
						("00000000000000000000000000000000");
end architecture yolo;
	