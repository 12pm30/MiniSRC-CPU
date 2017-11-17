library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ControlUnit_3Bus is
port (

			--clock/reset/stop
			clk, rst, stop : in std_logic;

			run_out : out std_logic;
			
			--register wr_en signals, ba_out signal
			c_r0_out, c_r1_out, c_r2_out, c_r3_out, c_r4_out, c_r5_out, c_r6_out, c_r7_out : out std_logic;
			c_r8_out, c_r9_out, c_r10_out, c_r11_out, c_r12_out, c_r13_out, c_r14_out, c_r15_out : out std_logic; 
			c_hilo_out, c_ir_out, c_pc_out, ba_out : out std_logic := '0';
			
			--out/in port enables
			out_port_en, in_port_en : out std_logic;
			
			--memory select/wr_en signal
			MAR_en, MAR_sel, MDR_en, MDR_sel, RAM_we : out std_logic;

			--bus/alu select signals
			a_bus_out, b_bus_out, fcn_sel : out std_logic_vector(4 downto 0);
			
			--c_sign_extended output
			c_sign_extended : out std_logic_vector(31 downto 0);
			
			--ir/bus inputs
			ir_in, a_in : in std_logic_vector(31 downto 0)
			
		);
end entity;

architecture finally of ControlUnit_3Bus is

component conff_3bus
	port
	(
		ir_in		:	 in std_logic_vector(1 downto 0);
		r_in		:	 in std_logic_vector(31 downto 0);
		result		:	 out std_logic
	);
end component;

component selectdecode_3bus
	port
	(
		ir_in		:	 in std_logic_vector(31 downto 0);
		c_sx		:	 out std_logic_vector(31 downto 0);
		rin		:	 in std_logic;
		gara		:	 in std_logic;
		garb		:	 in std_logic;
		garc		:	 in std_logic;
		gbra		:	 in std_logic;
		gbrb		:	 in std_logic;
		gbrc		:	 in std_logic;
		a_sel_out		:	 out std_logic_vector(3 downto 0);
		b_sel_out		:	 out std_logic_vector(3 downto 0);
		c_r0		:	 out std_logic;
		c_r1		:	 out std_logic;
		c_r2		:	 out std_logic;
		c_r3		:	 out std_logic;
		c_r4		:	 out std_logic;
		c_r5		:	 out std_logic;
		c_r6		:	 out std_logic;
		c_r7		:	 out std_logic;
		c_r8		:	 out std_logic;
		c_r9		:	 out std_logic;
		c_r10		:	 out std_logic;
		c_r11		:	 out std_logic;
		c_r12		:	 out std_logic;
		c_r13		:	 out std_logic;
		c_r14		:	 out std_logic;
		c_r15		:	 out std_logic
	);
end component;

--r_in signals from selectdecode
signal sd_rin : std_logic; --reset initialize to zero
signal sd_r0, sd_r1, sd_r2, sd_r3, sd_r4, sd_r5, sd_r6, sd_r7, sd_r8, sd_r9, sd_r10, sd_r11, sd_r12, sd_r13, sd_r14, sd_r15 : std_logic;

--bus select signals from selectdecode
signal sd_gAra, sd_gArb, sd_gArc, sd_gBra, sd_gBrb, sd_gBrc : std_logic; --reset initialize to zero
signal sd_a_sel, sd_b_sel : std_logic_vector(3 downto 0);

--bus select and register capture signals from control unit
signal cu_r0, cu_r1, cu_r2, cu_r3, cu_r4, cu_r5, cu_r6, cu_r7, cu_r8, cu_r9, cu_r10, cu_r11, cu_r12, cu_r13, cu_r14, cu_r15 : std_logic;
signal cu_a_sel, cu_b_sel : std_logic_vector(4 downto 0);

signal branch_result : std_logic;

type state is (S_reset,S_fetch,S_decode,S_LD_CMP,S_LD_MA,S_LDI,S_LDR_CMP,S_LDR_MA,S_ST_CMP,S_ST_MA,S_STR_CMP,S_STR_MA,S_IMM,S_OUT,S_IN,S_IN_LAG,S_MD,S_MFHL,S_BR_CMP,S_BR_PC,S_JAL,S_JR,S_ALU,S_NOP,S_HALT);

signal current_state : state;

begin

--ORing of the proper select/decode signals
c_r0_out <= cu_r0 OR sd_r0;
c_r1_out <= cu_r1 OR sd_r1;
c_r2_out <= cu_r2 OR sd_r2;
c_r3_out <= cu_r3 OR sd_r3;
c_r4_out <= cu_r4 OR sd_r4;
c_r5_out <= cu_r5 OR sd_r5;
c_r6_out <= cu_r6 OR sd_r6;
c_r7_out <= cu_r7 OR sd_r7;
c_r8_out <= cu_r8 OR sd_r8;
c_r9_out <= cu_r9 OR sd_r9;
c_r10_out <= cu_r10 OR sd_r10;
c_r11_out <= cu_r11 OR sd_r11;
c_r12_out <= cu_r12 OR sd_r12;
c_r13_out <= cu_r13 OR sd_r13;
c_r14_out <= cu_r14 OR sd_r14;
c_r15_out <= cu_r15 OR sd_r15;

--ORing of the A/B bus select signals
a_bus_out <= cu_a_sel or '0' & sd_a_sel;
b_bus_out <= cu_b_sel or '0' & sd_b_sel;



StateController : process(clk,rst,stop)
variable run : std_logic := '0';

begin
	run_out <= run;

	if rst = '1' then
		current_state <= S_reset;
		run := '1';
	elsif stop = '1' OR run = '0' then
		run := '0';
	elsif clk'event AND clk = '1' AND run = '1' then
		case current_state is
			when S_reset =>
				current_state <= S_fetch;
			when S_fetch =>
				current_state <= S_decode;
			when S_decode =>
				case ir_in(31 downto 27) is
					when "00000"=>
						current_state <= S_LD_CMP; --ld
					when "00001"=>
						current_state <= S_LDI; --ldi
					when "00010"=>
						current_state <= S_ST_CMP; --st
					when "00011"=>
						current_state <= S_LDR_CMP; --ldr
					when "00100"=>
						current_state <= S_STR_CMP; --str
					when "00101"=>
						current_state <= S_ALU; --add
					when "00110"=>
						current_state <= S_ALU; --sub
					when "00111"=>
						current_state <= S_ALU; --and
					when "01000"=>
						current_state <= S_ALU; --or
					when "01001"=>
						current_state <= S_ALU; --shr
					when "01010"=>
						current_state <= S_ALU; --shl
					when "01011"=>
						current_state <= S_ALU; --ror
					when "01100"=>
						current_state <= S_ALU; --rol
					when "01101"=>
						current_state <= S_IMM; --addi
					when "01110"=>
						current_state <= S_IMM; --andi
					when "01111"=>
						current_state <= S_IMM; --ori
					when "10000"=>
						current_state <= S_MD; --mul
					when "10001"=>
						current_state <= S_MD; --div
					when "10010"=>
						current_state <= S_ALU;--neg
					when "10011"=>
						current_state <= S_ALU;--not
					when "10100"=>
						current_state <= S_BR_CMP;--all variants of branch
					when "10101"=>
						current_state <= S_JR;--jr
					when "10110"=>
						current_state <= S_JAL;--jal
					when "10111"=>
						current_state <= S_IN;--in
					when "11000"=>
						current_state <= S_OUT;--out
					when "11001"=>
						current_state <= S_MFHL;--mfhi
					when "11010"=>
						current_state <= S_MFHL;--mflo
					when "11011"=>
						current_state <= S_NOP;--nop
					when "11100"=>
						run := '0';
						current_state <= S_HALT;--HALT! WHO GOES THERE?
					when others=>
						current_state <= S_NOP;
				end case;
			when S_LD_CMP =>
				current_state <= S_LD_MA;
			when S_LD_MA =>
				current_state <= S_fetch;
			when S_LDI =>
				current_state <= S_fetch;
			when S_LDR_CMP =>
				current_state <= S_LDR_MA;
			when S_LDR_MA =>
				current_state <= S_fetch;
			when S_ST_CMP =>
				current_state <= S_ST_MA;
			when S_ST_MA =>
				current_state <= S_fetch;
			when S_STR_CMP =>
				current_state <= S_STR_MA;
			when S_STR_MA =>
				current_state <= S_fetch;
			when S_IMM =>
				current_state <= S_fetch;
			when S_IN =>
				current_state <= S_IN_LAG;
			when S_IN_LAG =>
				current_state <= S_fetch;
			when S_OUT =>
				current_state <= S_fetch;
			when S_MD =>
				current_state <= S_fetch;
			when S_MFHL =>
				current_state <= S_Fetch;
			when S_BR_CMP =>
				current_state <= S_BR_PC;
			when S_BR_PC =>
				current_state <= S_Fetch;
			when S_JR =>
				current_state <= S_fetch;
			when S_JAL =>
				current_state <= S_JR;
			when S_ALU =>
				current_state <= S_fetch;
			when S_NOP =>
				current_state <= S_Fetch;
			when S_HALT =>
				current_state <= S_HALT;
			when others =>
				current_state <= S_Fetch;
		end case;
	end if;
end process;

StateResponder : process(current_state)
begin

case current_state is
	when S_reset =>
		
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "00000";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_fetch =>
		
		--selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10011";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '1';
		ba_out <= '0';
	
		--ALU function
		fcn_sel <= "01111";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '1';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '1';
		RAM_we <= '0';
	
	when S_decode =>
		
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10100";

		c_hilo_out <= '0';
		c_ir_out <= '1';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '1';
		RAM_we <= '0';
		
	when S_LD_CMP =>
		
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '1';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '1';
	
		--function
		fcn_sel <= "01001";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '1';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_LD_MA=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10100";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '1';
		RAM_we <= '0';
		
	when S_LDI=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '1';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '1';
	
		--function
		fcn_sel <= "01001";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_LDR_CMP=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "10011";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01001";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '1';
		MAR_sel <= '1';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
		
	when S_LDR_MA=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10100";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '1';
		RAM_we <= '0';
		
	when S_ST_CMP=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '1';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '1';
	
		--function
		fcn_sel <= "01001";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '1';
		MAR_sel <= '1';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_ST_MA=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '1';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '0';
		RAM_we <= '1';
	
	when S_STR_CMP=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "10011";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01001";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '1';
		MAR_sel <= '1';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_STR_MA=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '1';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '1';
		MDR_sel <= '0';
		RAM_we <= '1';
		
	when S_IMM=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '1';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10101";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
						
		if ir_in(31 downto 27) = "01101" then
			fcn_sel <= 	"01001"; --addi
		elsif ir_in(31 downto 27) = "01110" then
			fcn_sel <= 	"00001"; --andi
		elsif ir_in(31 downto 27) = "01111" then
			fcn_sel <= "00010"; --ori
		else
			fcn_sel <= "00000";
		end if;
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
	when S_OUT=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '1';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '1';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_IN=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10110";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '1';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';	
	
	when S_IN_LAG=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10110";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
	when S_MD=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '1';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '1';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '1';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		if ir_in(31 downto 27) = "10000" then
			fcn_sel <= 	"01011"; --mul
		elsif ir_in(31 downto 27) = "10001" then
			fcn_sel <= 	"01101"; --div
		else
			fcn_sel <= "00000";
		end if;
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_MFHL=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		
		if ir_in(31 downto 27) = "11001" then
			cu_b_sel <= "10000"; --mfhi
		elsif ir_in(31 downto 27) = "11010" then
			cu_b_sel <= "10001"; --mflo
		else
			cu_b_sel <= "00000";
		end if;
		
		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_BR_CMP=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '1';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '1';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_BR_PC=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '1';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '1';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		
		--c_pc_out <= '0';
		if branch_result = '1' then c_pc_out <= '1'; else c_pc_out <= '0'; end if;
		
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_JAL=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '1';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "10011";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
	when S_JR=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '1';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
   	cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '1';
		ba_out <= '0';
	
		--function
		fcn_sel <= "01100";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
		
	when S_ALU=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '1';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '1';
		sd_rin  <= '1';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
		cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		if ir_in(31 downto 27) = "00101" then
			fcn_sel <= 	"01001"; --add
		elsif ir_in(31 downto 27) = "00110" then
			fcn_sel <= 	"01000"; --sub
		elsif ir_in(31 downto 27) = "00111" then
			fcn_sel <= 	"00001"; --and
		elsif ir_in(31 downto 27) = "01000" then
			fcn_sel <= 	"00010"; --or
		elsif ir_in(31 downto 27) = "01001" then
			fcn_sel <= 	"10001"; --shr
		elsif ir_in(31 downto 27) = "01010" then
			fcn_sel <= 	"10000"; --shl
		elsif ir_in(31 downto 27) = "01011" then
			fcn_sel <= 	"10101"; --ror
		elsif ir_in(31 downto 27) = "01100" then
			fcn_sel <= 	"10100"; --rol
		elsif ir_in(31 downto 27) = "10010" then
			fcn_sel <= 	"01010"; --neg
		elsif ir_in(31 downto 27) = "10011" then
			fcn_sel <= 	"00011"; --not
		--eventually stick the other instructions here...like XOR/XNOR/NAND/NOR/etc.
		else
			fcn_sel <= "00000";
		end if;
		
		
		
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
	when S_NOP=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
		cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "00000";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
	when S_HALT=>
	
		--reset selectdecode bus select signals
		sd_gAra <= '0';
		sd_gArb <= '0';
		sd_gArc <= '0';
		sd_gBra <= '0';
		sd_gBrb <= '0';
		sd_gbrc <= '0';
		sd_rin  <= '0';
		
		--reset register capture signals
		cu_r0 <= '0';
		cu_r1 <= '0';
		cu_r2 <= '0';
		cu_r3 <= '0';
		cu_r4 <= '0';
		cu_r5 <= '0';
		cu_r6 <= '0';
		cu_r7 <= '0';
		cu_r8 <= '0';
		cu_r9 <= '0';
		cu_r10 <= '0';
		cu_r11 <= '0';
		cu_r12 <= '0';
		cu_r13 <= '0';
		cu_r14 <= '0';
		cu_r15 <= '0';
		cu_a_sel <= "00000";
		cu_b_sel <= "00000";

		c_hilo_out <= '0';
		c_ir_out <= '0';
		c_pc_out <= '0';
		ba_out <= '0';
	
		--function
		fcn_sel <= "00000";
		
		--out/in port
		out_port_en <= '0';
		in_port_en <= '0';
	
		--memory select
		MAR_en <= '0';
		MAR_sel <= '0';
		MDR_en <= '0';
		MDR_sel <= '0';
		RAM_we <= '0';
	
end case;	
	
end process;

TheConFF : conFF_3Bus port map
(
	ir_in => ir_in(1 downto 0),
	r_in => a_in,
	result => branch_result
);

TheSelector : SelectDecode_3bus port map
(
			ir_in => ir_in,
			c_sx => c_sign_extended,
			rIN => sd_rin,
			gAra => sd_gAra,
			gArb => sd_gArb,
			gArc => sd_garc,
			gBra => sd_gbra,
			gBrb => sd_gbrb,
			gBrc => sd_gbrc,
			a_sel_out => sd_a_sel,
			b_sel_out => sd_b_sel,
			c_r0 => sd_r0,
			c_r1 => sd_r1,
			c_r2 => sd_r2,
			c_r3 => sd_r3,
			c_r4 => sd_r4,
			c_r5 => sd_r5,
			c_r6 => sd_r6,
			c_r7 => sd_r7,
			c_r8 => sd_r8,
			c_r9 => sd_r9,
			c_r10 => sd_r10,
			c_r11 => sd_r11,
			c_r12 => sd_r12,
			c_r13 => sd_r13,
			c_r14	=> sd_r14,
			c_r15 => sd_r15
);

end architecture;