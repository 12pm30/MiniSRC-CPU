library IEEE;
use IEEE.std_logic_1164.all;

entity Datapath_3Bus is
port 
(
		--bus and register results
		a_out, b_out, c_out, pc_out, ir_out: out std_logic_vector(31 downto 0);
		
		--c sign extended input (from select & decode logic)
		c_sx : in std_LOGIC_VECTOR(31 downto 0);
		
		--memory signals
		dp_md_out, dp_ma_out : out std_logic_vector(31 downto 0); --memory data out (from rMDR), memory address out (directly from MAR)
		dp_md_in : in std_logic_vector(31 downto 0); --memory data in (from Q port on RAM)
		MAR_en, MAR_sel, MDR_en, MDR_sel : in std_logic; --write enable and input select for MAR and MDR
		
		
		r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out,r8_out,r9_out,r10_out,r11_out,r12_out,r13_out,r14_out,r15_out, rHI_out, rLO_out : out std_LOGIC_VECTOR(31 downto 0); --outputs for various registers
		
		--bus source control signals, for A bus
		a_bus_sel, b_bus_sel : in std_LOGIC_VECTOR(4 downto 0);
		
		--register capture signals (C Bus)
		c_r0, c_r1, c_r2, c_r3, c_r4, c_r5, c_r6, c_r7, c_r8, c_r9, c_r10, c_r11, c_r12, c_r13, c_r14, c_r15, c_hilo : in std_logic;
		c_IR, c_PC : in std_logic;
	
		--BA_out for r0 (gates a zero onto whatever bus)
		ba_out : in std_logic;
		
		--clock and reset
		clk, rst : in std_logic;
		
		--ALU Function Select
		fsel : in std_LOGIC_VECTOR(4 downto 0);
		
		
		--i/o ports as required
		out_port : out std_logic_vector(31 downto 0);
		out_port_en : in std_logic;
		
		in_port : in std_logic_vector(31 downto 0);
		in_port_en : in std_logic
		
);
end entity;

architecture structure of Datapath_3Bus is

--the 3 buses
signal a_bus, b_bus, c_bus, c_bus_hi : std_logic_vector(31 downto 0);

--the register signals
signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, rHI, rLO, rPC, rIR, rMDR, rIN : std_LOGIC_VECTOR(31 downto 0);

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

COMPONENT reg32
	PORT
	(
		input		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		output		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		en		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		clk		:	 IN STD_LOGIC
	);
END COMPONENT;

COMPONENT reg32_asc
	PORT
	(
		input		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		output		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		en		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		clk		:	 IN STD_LOGIC
	);
END COMPONENT;

COMPONENT reg32_r0
	PORT
	(
		input		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		BaseAddr_out		:	 IN STD_LOGIC;
		output		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		en		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		clk		:	 IN STD_LOGIC
	);
END COMPONENT;

begin

a_out <= a_bus; --bus values
b_out <= b_bus;
c_out <= c_bus;

ir_out <= rIR; --IR and PC
pc_out <= rPC;

r0_out <= r0; --register data
r1_out <= r1;
r2_out <= r2;
r3_out <= r3;
r4_out <= r4;
r5_out <= r5;
r6_out <= r6;
r7_out <= r7;
r8_out<= r8;
r9_out<= r9;
r10_out<= r10;
r11_out<= r11;
r12_out<= r12;
r13_out<= r13;
r14_out<= r14;
r15_out<= r15;
rHI_out <= rHI;
rLO_out <= rLO;

dp_md_out <= rMDR; --memory address 

TheALU : PotatoALU port map
			(
				a_in => a_bus,
				b_in => b_bus,
				c_low_out => c_bus,
				c_hi_out => c_bus_hi,
				clk => clk,
				carry_in => '0',
				reset => rst,
				fcn_sel => fsel,
				overflow_out => open,
				underflow_out => open,
				carry_out => open
			);


Register0 : reg32_r0 port map
		(
			BaseAddr_out => ba_out,
			input => c_bus,
			output => r0,
			en => c_r0,
			reset => rst,
			clk => clk
		);
		
Register1 : reg32 port map
		(
			input => c_bus,
			output => r1,
			en => c_r1,
			reset => rst,
			clk => clk
		);
		
Register2 : reg32 port map
		(
			input => c_bus,
			output => r2,
			en => c_r2,
			reset => rst,
			clk => clk
		);
		
Register3 : reg32 port map
		(
			input => c_bus,
			output => r3,
			en => c_r3,
			reset => rst,
			clk => clk
		);
		
Register4 : reg32 port map
		(
			input => c_bus,
			output => r4,
			en => c_r4,
			reset => rst,
			clk => clk
		);
		
Register5 : reg32 port map
		(
			input => c_bus,
			output => r5,
			en => c_r5,
			reset => rst,
			clk => clk
		);
		
Register6 : reg32 port map
		(
			input => c_bus,
			output => r6,
			en => c_r6,
			reset => rst,
			clk => clk
		);
		
Register7 : reg32 port map
		(
			input => c_bus,
			output => r7,
			en => c_r7,
			reset => rst,
			clk => clk
		);
		
Register8 : reg32 port map
		(
			input => c_bus,
			output => r8,
			en => c_r8,
			reset => rst,
			clk => clk
		);
		
Register9 : reg32 port map
		(
			input => c_bus,
			output => r9,
			en => c_r9,
			reset => rst,
			clk => clk
		);
		
Register10 : reg32 port map
		(
			input => c_bus,
			output => r10,
			en => c_r10,
			reset => rst,
			clk => clk
		);
		
Register11 : reg32 port map
		(
			input => c_bus,
			output => r11,
			en => c_r11,
			reset => rst,
			clk => clk
		);
		
Register12 : reg32 port map
		(
			input => c_bus,
			output => r12,
			en => c_r12,
			reset => rst,
			clk => clk
		);
		
Register13 : reg32 port map
		(
			input => c_bus,
			output => r13,
			en => c_r13,
			reset => rst,
			clk => clk
		);
		
Register14 : reg32 port map
		(
			input => c_bus,
			output => r14,
			en => c_r14,
			reset => rst,
			clk => clk
		);

Register15 : reg32 port map
		(
			input => c_bus,
			output => r15,
			en => c_r15,
			reset => rst,
			clk => clk
		);		

RegisterHI : reg32 port map
		(
			input => c_bus_hi,
			output => rHI,
			en => c_hilo,
			reset => rst,
			clk => clk
		);
		
RegisterLO : reg32 port map
		(
			input => c_bus,
			output => rLO,
			en => c_hilo,
			reset => rst,
			clk => clk
		);
		
RegisterIR : reg32_asc port map
		(
			input => c_bus,
			output => rIR,
			en => c_ir,
			reset => rst,
			clk => clk
		);
		
RegisterPC : reg32 port map
		(
			input => c_bus,
			output => rPC,
			en => c_pc,
			reset => rst,
			clk => clk
		);
	

MemoryAddressReg : MemDataReg port map
		(
			BusMuxOut => b_bus,
			MDataIn => c_bus,
			read_sel => MAR_sel,
			clear => rst,
			clk => clk,
			mdr_en => MAR_en,
			MDR_out => dp_ma_out
		);
	
MemoryDataReg : MemDataReg port map
		(
			BusMuxOut => c_bus,
			MDataIn => dp_md_in,
			read_sel => MDR_sel,
			clear => rst,
			clk => clk,
			mdr_en => MDR_en,
			MDR_out => rMDR
		);


InputPort : reg32 port map
		(
			input => in_port,
			output => rIN,
			en => in_port_en,
			reset => rst,
			clk => clk
		);

OutputPort : reg32 port map
		(
			input => c_bus,
			output => out_port,
			en => out_port_en,
			reset => rst,
			clk => clk
		);
		
a_bus <= r0 when a_bus_sel = "00000" else
			r1 when a_bus_sel = "00001" else
			r2 when a_bus_sel = "00010" else
			r3 when a_bus_sel = "00011" else
			r4 when a_bus_sel = "00100" else
			r5 when a_bus_sel = "00101" else
			r6 when a_bus_sel = "00110" else
			r7 when a_bus_sel = "00111" else
			r8 when a_bus_sel = "01000" else
			r9 when a_bus_sel = "01001" else
			r10 when a_bus_sel = "01010" else
			r11 when a_bus_sel = "01011" else
			r12 when a_bus_sel = "01100" else
			r13 when a_bus_sel = "01101" else
			r14 when a_bus_sel = "01110" else
			r15 when a_bus_sel = "01111" else
			rHI when a_bus_sel = "10000" else
			rLO when a_bus_sel = "10001" else
			rIR when a_bus_sel = "10010" else
			rPC when a_bus_sel = "10011" else
			rMDR when a_bus_sel = "10100" else
			c_sx when a_bus_sel = "10101" else
			rIN when a_bus_sel = "10110" else
			"00000000000000000000000000000000";

b_bus <= r0 when b_bus_sel = "00000" else
			r1 when b_bus_sel = "00001" else
			r2 when b_bus_sel = "00010" else
			r3 when b_bus_sel = "00011" else
			r4 when b_bus_sel = "00100" else
			r5 when b_bus_sel = "00101" else
			r6 when b_bus_sel = "00110" else
			r7 when b_bus_sel = "00111" else
			r8 when b_bus_sel = "01000" else
			r9 when b_bus_sel = "01001" else
			r10 when b_bus_sel = "01010" else
			r11 when b_bus_sel = "01011" else
			r12 when b_bus_sel = "01100" else
			r13 when b_bus_sel = "01101" else
			r14 when b_bus_sel = "01110" else
			r15 when b_bus_sel = "01111" else
			rHI when b_bus_sel = "10000" else
			rLO when b_bus_sel = "10001" else
			rIR when b_bus_sel = "10010" else
			rPC when b_bus_sel = "10011" else
			rMDR when b_bus_sel = "10100" else
			c_sx when b_bus_sel = "10101" else
			rIN when b_bus_sel = "10110" else
			"00000000000000000000000000000000";


end architecture;