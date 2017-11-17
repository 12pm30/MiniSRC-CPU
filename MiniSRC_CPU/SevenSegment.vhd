library ieee;
use ieee.std_logic_1164.all;

entity SevenSegment is
port	(
			inputPort : in std_logic_vector(31 downto 0);
			progCount : in std_logic_vector(31 downto 0);
			
			bankSwitch: in std_logic;
			
			digit0 : out std_logic_vector(6 downto 0);
			digit1 : out std_logic_vector(6 downto 0);
			digit2 : out std_logic_vector(6 downto 0);
			digit3 : out std_logic_vector(6 downto 0)

		);
end entity;

architecture behav of SevenSegment is
begin

digit0 <= 	"1000000" when inputPort(3 downto 0) = "0000" else
				"1111001" when inputPort(3 downto 0) = "0001" else
				"0100100" when inputPort(3 downto 0) = "0010" else
				"0110000" when inputPort(3 downto 0) = "0011" else
				"0011001" when inputPort(3 downto 0) = "0100" else
				"0010010" when inputPort(3 downto 0) = "0101" else
				"0000010" when inputPort(3 downto 0) = "0110" else
				"1111000" when inputPort(3 downto 0) = "0111" else
				"0000000" when inputPort(3 downto 0) = "1000" else
				"0011000" when inputPort(3 downto 0) = "1001" else
				"0001000" when inputPort(3 downto 0) = "1010" else
				"0000011" when inputPort(3 downto 0) = "1011" else
				"0100111" when inputPort(3 downto 0) = "1100" else
				"0100001" when inputPort(3 downto 0) = "1101" else
				"0000110" when inputPort(3 downto 0) = "1110" else
				"0001110" when inputPort(3 downto 0) = "1111" else
				"0000000";

digit1 <= 	"1000000" when inputPort(7 downto 4) = "0000" else
				"1111001" when inputPort(7 downto 4) = "0001" else
				"0100100" when inputPort(7 downto 4) = "0010" else
				"0110000" when inputPort(7 downto 4) = "0011" else
				"0011001" when inputPort(7 downto 4) = "0100" else
				"0010010" when inputPort(7 downto 4) = "0101" else
				"0000010" when inputPort(7 downto 4) = "0110" else
				"1111000" when inputPort(7 downto 4) = "0111" else
				"0000000" when inputPort(7 downto 4) = "1000" else
				"0011000" when inputPort(7 downto 4) = "1001" else
				"0001000" when inputPort(7 downto 4) = "1010" else
				"0000011" when inputPort(7 downto 4) = "1011" else
				"0100111" when inputPort(7 downto 4) = "1100" else
				"0100001" when inputPort(7 downto 4) = "1101" else
				"0000110" when inputPort(7 downto 4) = "1110" else
				"0001110" when inputPort(7 downto 4) = "1111" else
				"0000000";		

digit2 <= 	"1000000" when progCount(3 downto 0) = "0000" else
				"1111001" when progCount(3 downto 0) = "0001" else
				"0100100" when progCount(3 downto 0) = "0010" else
				"0110000" when progCount(3 downto 0) = "0011" else
				"0011001" when progCount(3 downto 0) = "0100" else
				"0010010" when progCount(3 downto 0) = "0101" else
				"0000010" when progCount(3 downto 0) = "0110" else
				"1111000" when progCount(3 downto 0) = "0111" else
				"0000000" when progCount(3 downto 0) = "1000" else
				"0011000" when progCount(3 downto 0) = "1001" else
				"0001000" when progCount(3 downto 0) = "1010" else
				"0000011" when progCount(3 downto 0) = "1011" else
				"0100111" when progCount(3 downto 0) = "1100" else
				"0100001" when progCount(3 downto 0) = "1101" else
				"0000110" when progCount(3 downto 0) = "1110" else
				"0001110" when progCount(3 downto 0) = "1111" else
				"0000000";
				
digit3 <= 	"1000000" when progCount(7 downto 4) = "0000" else
				"1111001" when progCount(7 downto 4) = "0001" else
				"0100100" when progCount(7 downto 4) = "0010" else
				"0110000" when progCount(7 downto 4) = "0011" else
				"0011001" when progCount(7 downto 4) = "0100" else
				"0010010" when progCount(7 downto 4) = "0101" else
				"0000010" when progCount(7 downto 4) = "0110" else
				"1111000" when progCount(7 downto 4) = "0111" else
				"0000000" when progCount(7 downto 4) = "1000" else
				"0011000" when progCount(7 downto 4) = "1001" else
				"0001000" when progCount(7 downto 4) = "1010" else
				"0000011" when progCount(7 downto 4) = "1011" else
				"0100111" when progCount(7 downto 4) = "1100" else
				"0100001" when progCount(7 downto 4) = "1101" else
				"0000110" when progCount(7 downto 4) = "1110" else
				"0001110" when progCount(7 downto 4) = "1111" else		
				"0000000";
				
end architecture;