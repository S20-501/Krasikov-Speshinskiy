library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity Assembled_generator_top is
    port (
      reset : in std_logic;
      DAC_Clk : out std_logic;
      DAC_Rst : out std_logic;
      DAC_Write : out std_logic;
      DAC_Select : out std_logic;
      DAC_Data : out std_logic_vector(9 downto 0);
		  c0 : in std_logic;
		  c1 : in std_logic
    );
end entity Assembled_generator_top;

architecture rtl of Assembled_generator_top is

    component generator_top
        port (
            clk : in std_logic;
            nRst : in std_logic;
            DDS_en_s : in std_logic;
            DDS_mode_s : in std_logic_vector(1 downto 0);
            DDS_amplitude_s : in std_logic_vector(15 downto 0);
            DDS_frequency_s : in std_logic_vector(31 downto 0);
            DDS_start_phase_s : in std_logic_vector(15 downto 0);
            DAC_I_s : out std_logic_vector(9 downto 0);
            DAC_Q_s : out std_logic_vector(9 downto 0)
      );
    end component;

	 
component modulator
    port (
    clk : in std_logic;
    nRst : in std_logic;
    ModulationMode : in std_logic_vector(1 downto 0);
    Mode : in std_logic;
    Amplitude : out std_logic_vector(15 downto 0);
    StartPhase : out std_logic_vector(15 downto 0);
    SymbolFrequency : in std_logic_vector(31 downto 0);
    DataPort : in std_logic_vector(15 downto 0);
    rdreq : out std_logic;
    empty : in std_logic;
    DDS_en : out std_logic
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

  component DACControlModule
    port (
        Clk : in std_logic;
        nRst : in std_logic;
        DAC_I_sig : in std_logic_vector(9 downto 0);
        DAC_Q_sig : in std_logic_vector(9 downto 0);
        Rst_For_DAC : in std_logic;
        Power_Down : in std_logic;
        DAC_Clk : out std_logic;
        DAC_Rst : out std_logic;
        DAC_Write : out std_logic;
        DAC_Select : out std_logic;
        DAC_Data : out std_logic_vector(9 downto 0)
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
  CarrierFrequency_OUT : out std_logic_vector(31 downto 0);
  SymbolFrequency_OUT : out std_logic_vector( 31 downto 0);
  rdreq : in STD_LOGIC;
  empty : out STD_LOGIC;
  full : out STD_LOGIC;
  q : out STD_LOGIC_VECTOR (15 DOWNTO 0);
  usedw : out STD_LOGIC_VECTOR (9 DOWNTO 0)
);
end component;
  
    --DAC control
-- signal Clk : std_logic;
-- signal nRst : std_logic;
signal DAC_I_sig : std_logic_vector(9 downto 0);
signal DAC_Q_sig : std_logic_vector(9 downto 0);
signal Rst_For_DAC : std_logic;
signal Power_Down : std_logic;
-- signal DAC_Clk : std_logic;
-- signal DAC_Rst : std_logic;
-- signal DAC_Write : std_logic;
-- signal DAC_Select : std_logic;
-- signal DAC_Data : std_logic_vector(9 downto 0);

--generator_top
-- signal clk : std_logic;
-- signal nRst : std_logic;
signal DDS_en_s : std_logic;
signal DDS_mode_s : std_logic_vector(1 downto 0);
signal DDS_amplitude_s : std_logic_vector(15 downto 0);
signal DDS_frequency_s : std_logic_vector(31 downto 0);
signal DDS_start_phase_s : std_logic_vector(15 downto 0);
signal DAC_I_s : std_logic_vector(9 downto 0);
signal DAC_Q_s : std_logic_vector(9 downto 0);

--modulator
-- signal clk : std_logic;
-- signal nRst : std_logic;
signal ModulationMode : std_logic_vector(1 downto 0);
signal Mode : std_logic;
signal Amplitude : std_logic_vector(15 downto 0);
signal StartPhase : std_logic_vector(15 downto 0);
signal SymbolFrequency : std_logic_vector(31 downto 0);
signal DataPort : std_logic_vector(15 downto 0);
signal rdreq : std_logic;
signal empty : std_logic;
signal DDS_en : std_logic;




--GSMRegistr
signal WB_Addr : std_logic_vector( 15 downto 0 );
signal WB_Ack : std_logic;
signal Clk : std_logic;
signal WB_DataIn : std_logic_vector( 15 downto 0 );
signal WB_DataOut : std_logic_vector( 15 downto 0 );
signal nRst : std_logic;
signal WB_Sel : std_logic_vector( 1 downto 0 );
signal WB_STB : std_logic;
signal WB_WE : std_logic;
signal WB_Cyc : std_logic;
signal WB_CTI : std_logic_vector(2 downto 0);
signal PRT_O : std_logic_vector( 15 downto 0 );
signal CarrierFrequency_OUT : std_logic_vector(31 downto 0);
signal SymbolFrequency_OUT : std_logic_vector( 31 downto 0);
-- signal rdreq : STD_LOGIC;
-- signal empty : STD_LOGIC;
signal full : STD_LOGIC;
signal q : STD_LOGIC_VECTOR (15 DOWNTO 0);
signal usedw : STD_LOGIC_VECTOR (9 DOWNTO 0);



--protocol exchange module
-- signal Clk : std_logic;
-- signal nRst : std_logic;
signal FT2232H_FSCTS : std_logic;
signal FT2232H_FSDO : std_logic;
signal FT2232H_FSDI : std_logic;
signal FT2232H_FSCLK : std_logic;
signal data_input : STD_LOGIC_VECTOR (15 DOWNTO 0);
signal rdreq_output : STD_LOGIC;
signal wrreq_input : STD_LOGIC;
signal q_output : STD_LOGIC_VECTOR (15 DOWNTO 0);
signal usedw_input_count : STD_LOGIC_VECTOR (10 DOWNTO 0);
signal usedw_output_count : STD_LOGIC_VECTOR (10 DOWNTO 0);

-- signal Clk : std_logic;
-- signal nRst : std_logic;
signal q_input : std_logic_vector (15 downto 0);
signal usedw_input_fi : std_logic_vector (10 downto 0);
-- signal rdreq_output : std_logic;
signal data_output : std_logic_vector (15 downto 0);
signal usedw_input_fo : std_logic_vector (10 downto 0);
signal wrreq_output : std_logic;
-- signal WB_Addr : std_logic_vector (15 downto 0);
-- signal WB_DataOut : std_logic_vector (15 downto 0);
signal WB_DataIn_0 : std_logic_vector (15 downto 0);
signal WB_DataIn_1 : std_logic_vector (15 downto 0);
signal WB_DataIn_2 : std_logic_vector (15 downto 0);
signal WB_DataIn_3 : std_logic_vector (15 downto 0);
-- signal WB_WE : std_logic;
-- signal WB_Sel : std_logic_vector (1 downto 0);
-- signal WB_STB : std_logic;
signal WB_Cyc_0 : std_logic;
signal WB_Cyc_1 : std_logic;
signal WB_Cyc_2 : std_logic;
signal WB_Cyc_3 : std_logic;
-- signal WB_Ack : std_logic;
-- signal WB_CTI : std_logic_vector (2 downto 0);


begin

  
  modulator_inst : modulator
  port map (
    clk => c0,
    nRst => reset,
    ModulationMode => PRT_O(2 downto 1),
    Mode => PRT_O(0),
    Amplitude => Amplitude,
    StartPhase => StartPhase,
    SymbolFrequency => SymbolFrequency,
    DataPort => DataPort,
    rdreq => rdreq,
    empty => empty,
    DDS_en => DDS_en
  );


  generator_top_inst : generator_top
  port map (
    clk => c0,
    nRst => reset,
    DDS_en_s => DDS_en,
    DDS_mode_s => DDS_mode_s,--
    DDS_amplitude_s => Amplitude,--почему в 3 модулях
    DDS_frequency_s => DDS_frequency_s,--
    DDS_start_phase_s => StartPhase,--почему в 3 модулях
    DAC_I_s => DAC_I_s,
    DAC_Q_s => DAC_Q_s
  );

  Protocol_exchange_module_inst : Protocol_exchange_module
  port map (
    Clk => c0,
    nRst => reset,
    q_input => q_input,
    usedw_input_fi => usedw_input_fi,
    rdreq_output => rdreq_output,
    data_output => data_output,
    usedw_input_fo => usedw_input_fo,
    wrreq_output => wrreq_output,
    WB_Addr => WB_Addr,
    WB_DataOut => WB_DataOut,
    WB_DataIn_0 => WB_DataIn_0,
    WB_DataIn_1 => WB_DataIn_1,--
    WB_DataIn_2 => WB_DataIn_2,--должен быть гетеродин, но он открестился
    WB_DataIn_3 => WB_DataIn_3,--
    WB_WE => WB_WE,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_Cyc_0 => WB_Cyc_0,
    WB_Cyc_1 => WB_Cyc_1,
    WB_Cyc_2 => WB_Cyc_2,--
    WB_Cyc_3 => WB_Cyc_3,--
    WB_Ack => WB_Ack,
    WB_CTI => WB_CTI
  );

  ProtocolExchangeModule_inst : ProtocolExchangeModule
  port map (
     Clk => c0,
    nRst => reset,
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

  DACControlModule_inst : DACControlModule
  port map (
    Clk => c0,
    nRst => reset,
    DAC_I_sig => DAC_I_s,
    DAC_Q_sig => DAC_Q_s,
    Rst_For_DAC => '0',--установить в 0
    Power_Down => '0',--установить в 0?
    --на выход
    DAC_Clk => DAC_Clk,--
    DAC_Rst => DAC_Rst,--
    DAC_Write => DAC_Write,--
    DAC_Select => DAC_Select,--
    DAC_Data => DAC_Data--
  );

  GSMRegistr_top_inst : GSMRegistr_top
  port map (
    WB_Addr => WB_Addr,
    WB_Ack => WB_Ack,--
    Clk => c0,
    WB_DataIn => WB_DataOut,
    WB_DataOut => WB_DataIn_0,
    nRst => reset,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_WE => WB_WE,
    WB_Cyc => WB_Cyc_0,
    WB_CTI => WB_CTI,
    PRT_O => PRT_O,
    -- Amplitude_OUT => Amplitude_OUT,--
    -- StartPhase_OUT => StartPhase_OUT,--
    -- CarrierFrequency_OUT => CarrierFrequency,
    SymbolFrequency_OUT => SymbolFrequency,
    rdreq => rdreq,
    empty => empty,--к азату?
    full => full,--
    q => DataPort,
    usedw => usedw--
  );




end architecture;