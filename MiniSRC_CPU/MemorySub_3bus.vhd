library ieee;
use iee.std_logic_1164.all;

entity MemorySub_3bus is
port	( 	mdata_in		: in std_logic_vector(31 downto 0);
			maddr_in		: in std_logic_vector(31 downto 0);
			mdata_out	: out std_logic_vector(31 dowto 0);
			
			memAddrWrite : in std_logic;
			
			
		)
end entity;