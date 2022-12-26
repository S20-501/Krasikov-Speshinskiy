library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Assembled_top is
  port (
    CLK12M : in std_logic;
    reset : in std_logic

  );
end entity Assembled_top;


architecture rtl of Assembled_top is
    
-----------------PLL
    component TOP_PLL
        port (
        areset : in STD_LOGIC;
        inclk0 : in STD_LOGIC;
        c0 : out STD_LOGIC;
        c1 : out STD_LOGIC;
        locked : out STD_LOGIC
      );
    end component;
   
    
-----------------Tester   
/*    component Assembled_tester
        port (
        FT2232H_FSDI : in std_logic;
        FT2322H_FSCLK : in std_logic;
        tester_clk : out std_logic;
        tester_reset : out std_logic;
        FT2232H_FSCTS : out std_logic;
        FT2232H_FSDO : out std_logic
      );
    end component;
  */  

-----------------Generator
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


component GSMRegistr_top
    port (
    WB_Addr_IN : in std_logic_vector( 15 downto 0 );
    WB_Ack_OUT : out std_logic;
    Clk : in std_logic;
    WB_Data_IN : in std_logic_vector( 15 downto 0 );
    WB_Data_OUT : out std_logic_vector( 15 downto 0 );
    nRst : in std_logic;
    WB_Sel_IN : in std_logic_vector( 1 downto 0 );
    WB_STB_IN : in std_logic;
    WB_WE_IN : in std_logic;
    WB_Cyc : in std_logic;
    WB_CTI : in std_logic_vector(2 downto 0);
    PRT_O : out std_logic_vector( 15 downto 0 );
    Amplitude_OUT : out std_logic_vector( 15 downto 0);
    StartPhase_OUT : out std_logic_vector( 15 downto 0);
    CarrierFrequency_OUT : out std_logic_vector(31 downto 0);
    SymbolFrequency_OUT : out std_logic_vector( 31 downto 0);
    rdreq : in STD_LOGIC;
    empty : out STD_LOGIC;
    full : out STD_LOGIC;
    q : out STD_LOGIC_VECTOR (15 DOWNTO 0);
    usedw : out STD_LOGIC_VECTOR (9 DOWNTO 0)
  );
end component;


component modulator
    port (
    clk : in std_logic;
    nRst : in std_logic;
    Sync : in std_logic;
    SignalMode : in std_logic_vector(1 downto 0);
    ModulationMode : in std_logic_vector(1 downto 0);
    Mode : in std_logic;
    AmpErr : in std_logic;
    Amplitude : out std_logic_vector(15 downto 0);
    StartPhase : out std_logic_vector(15 downto 0);
    CarrierFrequency : in std_logic_vector(31 downto 0);
    SymbolFrequency : in std_logic_vector(31 downto 0);
    DataPort : in std_logic_vector(15 downto 0);
    rdreq : out std_logic;
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


-----------------Analyzer
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


  component demultiplexer_top
    port (
      Clk_ADC : in std_logic;
      Clk_DataFlow : in std_logic;
      nRst : in std_logic;
      ReceiveDataMode : in std_logic;
      ADC_SigIn : in std_logic_vector(9 downto 0);
      ISigOut : out std_logic_vector(9 downto 0);
      QSigOut : out std_logic_vector(9 downto 0);
      DataStrobe : out std_logic;
      Gain_s : out std_logic;
      OutputBusSelect_s : out std_logic;
      Standby_s : out std_logic;
      PowerDown_s : out std_logic;
      OffsetCorrect_s : out std_logic;
      OutputFormat_s : out std_logic
    );
  end component;


  component Geterodine_module
    port (
      WB_ADDR_IN : in std_logic_vector(15 downto 0);
      WB_ACK_OUT : out std_logic;
      WB_DATA_IN_0 : in std_logic_vector(15 downto 0);
      WB_DATA_IN_1 : in std_logic_vector(15 downto 0);
      WB_DATA_IN_2 : in std_logic_vector(15 downto 0);
      WB_DATA_IN_3 : in std_logic_vector(15 downto 0);
      WB_DATA_OUT : out std_logic_vector(15 downto 0);
      WB_SEL_IN : in std_logic_vector(1 downto 0);
      WB_STB_IN : in std_logic;
      WB_WE : out std_logic;
      WB_Cyc_0 : out std_logic;
      WB_Cyc_1 : out std_logic;
      WB_Cyc_2 : out std_logic;
      WB_Cyc_3 : out std_logic;
      WB_Ack : out std_logic;
      WB_CTI : out std_logic_vector(2 downto 0);
      Clk : in std_logic;
      nRst : in std_logic;
      ReceiveDataMode : in std_logic;
      DataStrobe : in std_logic;
      ISig_In : in std_logic_vector(9 downto 0);
      QSig_In : in std_logic_vector(9 downto 0);
      FS_IncrDecr : in std_logic_vector(1 downto 0);
      IData_Out : out std_logic_vector(9 downto 0);
      QData_Out : out std_logic_vector(9 downto 0);
      DataValid : out std_logic;
      i_coeff_0 : in std_logic_vector(9 downto 0);
      i_coeff_1 : in std_logic_vector(9 downto 0);
      i_coeff_2 : in std_logic_vector(9 downto 0);
      i_coeff_3 : in std_logic_vector(9 downto 0)
    );
  end component;


  component MA
    port (
    i_clk : in std_logic;
    i_nRst : in std_logic;
    i_data : in std_logic_vector(10-1 downto 0);
    MANumber : in std_logic_vector(8-1 downto 0);
    o_data : out std_logic_vector(10-1 downto 0)
  );
end component;



  component demodulator_decoder_top
    port (
    clk : in std_logic;
    nRst : in std_logic;
    IData_In : in STD_LOGIC_VECTOR(9 downto 0);
    QData_In : in STD_LOGIC_VECTOR(9 downto 0);
    DataValid : in std_logic;
    DataStrobe : out std_logic;
    delay : out unsigned(9 downto 0);
    dataout : out std_logic_vector(7 downto 0)
  );
end component;



begin

-----------------PLL
    TOP_PLL_inst : TOP_PLL
    port map (
      areset => reset,
      inclk0 => CLK12M,
      c0 => c0, --40MHz
      c1 => c1, --80MHz
      locked => locked
    );
  

-----------------Tester
/*Assembled_tester_inst : Assembled_tester
  port map (
    FT2232H_FSDI => FT2232H_FSDI,
    FT2232H_FSCLK => FT2232H_FSCLK,
    tester_clk => tester_clk,
    tester_reset => tester_reset,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO
  );
*/

-----------------Generator
modulator_inst : modulator
  port map (
    clk => c0,
    nRst => reset OR locked,
    Sync => Sync,--
    SignalMode => SignalMode,--
    ModulationMode => ModulationMode,--
    Mode => Mode,--
    AmpErr => AmpErr,--
    Amplitude => Amplitude,--почему в 3 модулях
    StartPhase => StartPhase,--почему в 3 модулях
    CarrierFrequency => CarrierFrequency,
    SymbolFrequency => SymbolFrequency,
    DataPort => DataPort,--
    rdreq => rdreq,--
    DDS_en => DDS_en
  );


  generator_top_inst : generator_top
  port map (
    clk => c0,
    nRst => reset OR locked,
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
    nRst => reset OR locked,
    q_input => q_input,
    usedw_input_fi => usedw_input_fi,
    rdreq_output => rdreq_output,--
    data_output => data_output,
    usedw_input_fo => usedw_input_fo,
    wrreq_output => wrreq_output,
    WB_Addr => WB_Addr,--
    WB_DataOut => WB_DataOut,--
    WB_DataIn_0 => WB_DataIn_0,--
    WB_DataIn_1 => WB_DataIn_1,--
    WB_DataIn_2 => WB_DataIn_2,--
    WB_DataIn_3 => WB_DataIn_3,--
    WB_WE => WB_WE_IN,
    WB_Sel => WB_Sel,
    WB_STB => WB_STB,
    WB_Cyc_0 => WB_Cyc_0,--
    WB_Cyc_1 => WB_Cyc_1,--
    WB_Cyc_2 => WB_Cyc_2,--
    WB_Cyc_3 => WB_Cyc_3,--
    WB_Ack => WB_Ack_OUT,
    WB_CTI => WB_CTI_IN
  );



  ProtocolExchangeModule_inst : ProtocolExchangeModule
  port map (
    Clk => c0,
    nRst => reset OR locked,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO,
    FT2232H_FSDI => FT2232H_FSDI,
    FT2232H_FSCLK => FT2232H_FSCLK,
    data_input => data_output,
    rdreq_output => rdreq_output,--
    wrreq_input => wrreq_otput,
    q_output => q_input,
    usedw_input_count => usedw_input_fo,
    usedw_output_count => usedw_input_fi
  );


  GSMRegistr_top_inst : GSMRegistr_top
  port map (
    WB_Addr_IN => WB_Addr_IN,--
    WB_Ack_OUT => WB_Ack_OUT,
    Clk => c0,
    WB_Data_IN => WB_Data_IN,--
    WB_Data_OUT => WB_Data_OUT,--
    nRst => reset OR locked,
    WB_Sel_IN => WB_Sel,
    WB_STB_IN => WB_STB,
    WB_WE_IN => WB_WE_IN,
    WB_Cyc => WB_Cyc,--
    WB_CTI => WB_CTI_IN,
    PRT_O => PRT_O,--
    Amplitude_OUT => Amplitude,--почему в 3 модулях
    StartPhase_OUT => StartPhase,--почему в 3 модулях
    CarrierFrequency_OUT => CarrierFrequency,
    SymbolFrequency_OUT => SymbolFrequency,
    rdreq => rdreq,--
    empty => empty,--
    full => full,--
    q => q,--
    usedw => usedw--
  );


  DACControlModule_inst : DACControlModule
  port map (
    Clk => c0,
    nRst => nRst,
    DAC_I_sig => DAC_I_s,
    DAC_Q_sig => DAC_Q_s,
    Rst_For_DAC => Rst_For_DAC,--
    Power_Down => Power_Down,--
    DAC_Clk => DAC_Clk,--
    DAC_Rst => DAC_Rst,--
    DAC_Write => DAC_Write,--
    DAC_Select => DAC_Select,--
    DAC_Data => DAC_Data--
  );


-----------------Analyzer
----------------------------
DDS_inst : DDS
port map (
  clk => c0,
  nRst => reset OR locked,
  WB_Addr => WB_Addr,--
  WB_DataIn => WB_DataIn,--
  WB_WE => WB_WE,
  WB_Sel => WB_Sel,
  WB_STB => WB_STB,
  WB_Cyc => WB_Cyc,--
  WB_Ack => WB_Ack,
  WB_CTI => WB_CTI,
  DataFlow_Clk => Clk_DataFlow,
  ADC_Clk => Clk_ADC
);


demultiplexer_top_inst : demultiplexer_top
port map (
  Clk_ADC => Clk_ADC,
  Clk_DataFlow => Clk_DataFlow,
  nRst => reset OR locked,
  ReceiveDataMode => ReceiveDataMode,--
  ADC_SigIn => ADC_SigIn,--
  ISigOut => ISigOut,
  QSigOut => QSigOut,
  DataStrobe => DataStrobe,--
  Gain_s => Gain_s,--
  OutputBusSelect_s => OutputBusSelect_s,--
  Standby_s => Standby_s,--
  PowerDown_s => PowerDown_s,--
  OffsetCorrect_s => OffsetCorrect_s,--
  OutputFormat_s => OutputFormat_s--
);


Geterodine_module_inst : Geterodine_module--почему 2 WB_Ack
port map (
  WB_ADDR_IN => WB_ADDR_IN,--
  WB_ACK_OUT => WB_Ack,--
  WB_DATA_IN_0 => WB_DATA_IN_0,--
  WB_DATA_IN_1 => WB_DATA_IN_1,--
  WB_DATA_IN_2 => WB_DATA_IN_2,--
  WB_DATA_IN_3 => WB_DATA_IN_3,--
  WB_DATA_OUT => WB_DATA_OUT,--
  WB_SEL_IN => WB_Sel,
  WB_STB_IN => WB_STB,
  WB_WE => WB_WE,
  WB_Cyc_0 => WB_Cyc_0,--
  WB_Cyc_1 => WB_Cyc_1,--
  WB_Cyc_2 => WB_Cyc_2,--
  WB_Cyc_3 => WB_Cyc_3,--
  WB_Ack => WB_Ack,
  WB_CTI => WB_CTI,
  Clk => c0,
  nRst => reset OR locked,
  ReceiveDataMode => ReceiveDataMode,--
  DataStrobe => DataStrobe,--
  ISig_In => ISigOut,
  QSig_In => QSigOut,
  FS_IncrDecr => FS_IncrDecr,--
  IData_Out => IData_Out,
  QData_Out => QData_Out,
  DataValid => DataValid,
  i_coeff_0 => i_coeff_0,--
  i_coeff_1 => i_coeff_1,--
  i_coeff_2 => i_coeff_2,--
  i_coeff_3 => i_coeff_3--
);


MA_inst : MA
  port map (
    i_clk => c0,
    i_nRst => reset OR locked,
    i_data => i_data,--
    MANumber => MANumber,--
    o_data => o_data--
  );


  demodulator_decoder_top_inst : demodulator_decoder_top
  port map (
    clk => c0,
    nRst => reset OR locked,
    IData_In => IData_Out,
    QData_In => QData_Out,
    DataValid => DataValid,
    DataStrobe => DataStrobe,--
    delay => delay,--
    dataout => dataout--
  );


end architecture;