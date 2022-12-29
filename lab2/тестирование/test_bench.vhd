-- connector
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity test_bench is
  --port(
	 --FT2232H_FSDI : out std_logic;
    --FT2232H_FSCLK : out std_logic;
    --tester_clk : in std_logic;
    --tester_reset : in std_logic;
    --FT2232H_FSCTS : in std_logic;
    --FT2232H_FSDO : in std_logic
--);
end test_bench;

architecture conecter of test_bench is
	 
  signal FT2232H_FSDI : std_logic;
  signal FT2232H_FSCLK : std_logic;
  signal tester_clk : std_logic;
  signal tester_reset : std_logic;
  signal FT2232H_FSCTS : std_logic;
  signal FT2232H_FSDO : std_logic;

	 
  signal nRst : std_logic;
  signal q_input : std_logic_vector (15 downto 0);
  signal usedw_input_fi : std_logic_vector (10 downto 0);
  signal rdreq_output : std_logic;
  signal data_output : std_logic_vector (15 downto 0);
  signal usedw_input_fo : std_logic_vector (10 downto 0);
  signal wrreq_output : std_logic;
  signal WB_Addr : std_logic_vector (15 downto 0);
  signal WB_DataOut : std_logic_vector (15 downto 0);
  signal WB_DataIn_0 : std_logic_vector (15 downto 0);
  signal WB_DataIn_1 : std_logic_vector (15 downto 0);
  signal WB_DataIn_2 : std_logic_vector (15 downto 0);
  signal WB_DataIn_3 : std_logic_vector (15 downto 0);
  signal WB_WE : std_logic;
  signal WB_Sel : std_logic_vector (1 downto 0);
  signal WB_STB : std_logic;
  signal WB_Cyc_0 : std_logic;
  signal WB_Cyc_1 : std_logic;
  signal WB_Cyc_2 : std_logic;
  signal WB_Cyc_3 : std_logic;
  signal WB_Ack1 : std_logic;
  signal WB_Ack2 : std_logic;
  signal WB_CTI : std_logic_vector (2 downto 0);
  
  
  signal DataFlow_Clk : std_logic;
  signal ADC_Clk : std_logic;

  
  signal PRT_O : std_logic_vector( 15 downto 0 );
  signal Amplitude_OUT : std_logic_vector( 15 downto 0);
  signal StartPhase_OUT : std_logic_vector( 15 downto 0);
  signal CarrierFrequency_OUT : std_logic_vector(31 downto 0);
  signal SymbolFrequency_OUT : std_logic_vector( 31 downto 0);
  signal rdreq : STD_LOGIC;
  signal empty : STD_LOGIC;
  signal full : STD_LOGIC;
  signal q : STD_LOGIC_VECTOR (15 DOWNTO 0);
  signal usedw : STD_LOGIC_VECTOR (9 DOWNTO 0);



component Tester
	port(
		FT2232H_FSDI : in std_logic;
 		-- Входной тактовый сигнал для микросхемы FT2232H
    	FT2232H_FSCLK : in std_logic;
		-- общие сигналы
	   tester_clk : out std_logic ;
 	  	tester_reset : out std_logic ;
  	 	-- готовность FT к приму данных (0)
  	  	FT2232H_FSCTS : out std_logic;
 	  	-- канал передачи данных к FT
   		FT2232H_FSDO : out std_logic

	);
end component;	

component ProtocolExchangeModule
    port (
    Clk : in std_logic;
    nRst : in std_logic;
    FT2232H_FSCTS : in std_logic;
    FT2232H_FSDO : in std_logic;
    FT2232H_FSDI : out std_logic;
    FT2232H_FSCLK : out std_logic;
    data_input : in STD_LOGIC_VECTOR (15 DOWNTO 0);
    rdreq_output : in STD_LOGIC;
    wrreq_input : in STD_LOGIC;
    q_output : out STD_LOGIC_VECTOR (15 DOWNTO 0);
    usedw_input_count : out STD_LOGIC_VECTOR (10 DOWNTO 0);
    usedw_output_count : out STD_LOGIC_VECTOR (10 DOWNTO 0)
  );
end component;

component Protocol_exchange_module
    port (
    Clk : in std_logic;
    nRst : in std_logic;
    q_input : in std_logic_vector (15 downto 0);
    usedw_input_fi : in std_logic_vector (10 downto 0);
    rdreq_output : out std_logic;
    data_output : out std_logic_vector (15 downto 0);
    usedw_input_fo : in std_logic_vector (10 downto 0);
    wrreq_output : out std_logic;
    WB_Addr : out std_logic_vector (15 downto 0);
    WB_DataOut : out std_logic_vector (15 downto 0);
    WB_DataIn_0 : in std_logic_vector (15 downto 0);
    WB_DataIn_1 : in std_logic_vector (15 downto 0);
    WB_DataIn_2 : in std_logic_vector (15 downto 0);
    WB_DataIn_3 : in std_logic_vector (15 downto 0);
    WB_WE : out std_logic;
    WB_Sel : out std_logic_vector (1 downto 0);
    WB_STB : out std_logic;
    WB_Cyc_0 : out std_logic;
    WB_Cyc_1 : out std_logic;
    WB_Cyc_2 : out std_logic;
    WB_Cyc_3 : out std_logic;
    WB_Ack : in std_logic;
    WB_CTI : out std_logic_vector (2 downto 0)
  );
end component;

component DDS
    port (
    clk : in std_logic;
    nRst : in std_logic;
    WB_Addr : in std_logic_vector(15 downto 0);
    WB_DataOut : out std_logic_vector(15 downto 0);
    WB_DataIn : in std_logic_vector(15 downto 0);
    WB_WE : in std_logic;
    WB_Sel : in std_logic_vector(1 downto 0);
    WB_STB : in std_logic;
    WB_Cyc : in std_logic;
    WB_Ack : out std_logic;
    WB_CTI : in std_logic_vector(2 downto 0);
    DataFlow_Clk : out std_logic;
    ADC_Clk : out std_logic
  );
end component;

component GSMRegistr_top
    port (
    WB_Addr : in std_logic_vector( 15 downto 0 );
    WB_Ack : out std_logic;
    Clk : in std_logic;
    WB_DataIn : in std_logic_vector( 15 downto 0 );
    WB_DataOut : out std_logic_vector( 15 downto 0 );
    nRst : in std_logic;
    WB_Sel : in std_logic_vector( 1 downto 0 );
    WB_STB : in std_logic;
    WB_WE : in std_logic;
    WB_Cyc : in std_logic;
    WB_CTI : in std_logic_vector(2 downto 0);
    PRT_O : out std_logic_vector( 15 downto 0 );
    --Amplitude_OUT : out std_logic_vector( 15 downto 0);
    --StartPhase_OUT : out std_logic_vector( 15 downto 0);
    CarrierFrequency_OUT : out std_logic_vector(31 downto 0);
    SymbolFrequency_OUT : out std_logic_vector( 31 downto 0);
    rdreq : in STD_LOGIC;
    empty : out STD_LOGIC;
    full : out STD_LOGIC;
    q : out STD_LOGIC_VECTOR (15 DOWNTO 0);
    usedw : out STD_LOGIC_VECTOR (9 DOWNTO 0)
  );
end component;

	
begin

Tester_inst : Tester
  port map (
    FT2232H_FSDI => FT2232H_FSDI,
    FT2232H_FSCLK => FT2232H_FSCLK,
    tester_clk => tester_clk,
    tester_reset => tester_reset,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO
  );


DDS_inst : DDS
  port map (
    clk => tester_clk,
    nRst => tester_reset,
    WB_Addr => WB_Addr,
    WB_DataOut => WB_DataIn_1,
    WB_DataIn => WB_DataOut,
    WB_WE => WB_WE,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_Cyc => WB_Cyc_1,
    WB_Ack => WB_Ack2,
    WB_CTI => WB_CTI,
    DataFlow_Clk => DataFlow_Clk,--
    ADC_Clk => ADC_Clk--
  );

  
  GSMRegistr_top_inst : GSMRegistr_top
  port map (
    WB_Addr => WB_Addr,
    WB_Ack => WB_Ack1,
    Clk => tester_clk,
    WB_DataIn => WB_DataOut,
    WB_DataOut => WB_DataIn_0,
    nRst => tester_reset,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_WE => WB_WE,
    WB_Cyc => WB_Cyc_0,
    WB_CTI => WB_CTI,
    PRT_O => PRT_O,
    --Amplitude_OUT => Amplitude_OUT,
    --StartPhase_OUT => StartPhase_OUT,
    CarrierFrequency_OUT => CarrierFrequency_OUT,
    SymbolFrequency_OUT => SymbolFrequency_OUT,
    rdreq => rdreq,
    empty => empty,
    full => full,
    q => q,
    usedw => usedw
  );

	
	ProtocolExchangeModule_inst : ProtocolExchangeModule
  port map (
    Clk => tester_clk,
    nRst => tester_reset,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO,
    FT2232H_FSDI => FT2232H_FSDI,
    FT2232H_FSCLK => FT2232H_FSCLK,
    data_input => data_output,
    rdreq_output => rdreq_output,
    wrreq_input => wrreq_output,
    q_output => q_input,
    usedw_input_count => usedw_input_fo,
    usedw_output_count => usedw_input_fi
  );
  
  Protocol_exchange_module_inst : Protocol_exchange_module
  port map (
    Clk => tester_clk,
    nRst => tester_reset,
    q_input => q_input,
    usedw_input_fi => usedw_input_fi,
    rdreq_output => rdreq_output,
    data_output => data_output,
    usedw_input_fo => usedw_input_fo,
    wrreq_output => wrreq_output,
    WB_Addr => WB_Addr,
    WB_DataOut => WB_DataOut,
    WB_DataIn_0 => WB_DataIn_0,
    WB_DataIn_1 => WB_DataIn_1,
    WB_DataIn_2 => WB_DataIn_2,
    WB_DataIn_3 => WB_DataIn_3,
    WB_WE => WB_WE,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_Cyc_0 => WB_Cyc_0,
    WB_Cyc_1 => WB_Cyc_1,
    WB_Cyc_2 => WB_Cyc_2,
    WB_Cyc_3 => WB_Cyc_3,
    WB_Ack => WB_Ack2,--WB_Ack1 OR WB_Ack2
    WB_CTI => WB_CTI
  );


end conecter;	
