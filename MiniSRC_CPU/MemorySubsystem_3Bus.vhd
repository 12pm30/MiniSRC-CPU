library ieee;
use ieee.std_logic_1164.all;

entity MemorySubsystem_3Bus is
port		(
					MemDataIn_B, MemDataIn_C : in std_logic_vector(31 downto 0); --connection to B&C buses
					MemDataOut : out std_logic_vector(31 downto 0); --B&
					reset, clock, MAR_en, MAR_sel, MDR_en, MDR_sel, WR_en : in std_logic
			);
end entity;

architecture yolo of MemorySubsystem_3Bus is

component RamMemory
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

COMPONENT MemDataReg
	PORT
	(
		BusMuxOut		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MDataIn		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_sel		:	 IN STD_LOGIC;
		clear		:	 IN STD_LOGIC;
		clk		:	 IN STD_LOGIC;
		mdr_en		:	 IN STD_LOGIC;
		MDR_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;



signal memaddr : std_logic_vector(31 downto 0); 		--memory address before truncation

signal memdata_out : std_LOGIC_VECTOR(31 downto 0); 	--data from mem data reg - goes to memory input and memdata out
signal q_out : std_logic_vector(31 downto 0); 			--data from memory, to mem data register

begin

memDataOut <= memdata_out;

MemAddrReg : MemDataReg port map
				(
					BusMuxOut => MemDataIn_B,
					MDataIn => MemDataIn_C,
					read_sel => MAR_sel,
					clear => reset,
					clk => clock,
					mdr_en => MAR_en,
					MDR_out => memaddr
				);

TheMemory : RamMemory port map (
				address => memaddr(8 downto 0),
				clock => clk,
				data => memdata_out,
				wren => wr_en,
				q => q_out
				);
				
MemoryData : MemDataReg port map (
					BusMuxOut => MemDataIn_C,
					MDataIn => q_out,
					read_sel => MDR_sel,
					clear => reset,
					clk => clock,
					mdr_en => MDR_en,
					MDR_out => memdata_out
				);
				
end architecture;