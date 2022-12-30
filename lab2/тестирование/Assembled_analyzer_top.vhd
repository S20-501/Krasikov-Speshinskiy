library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Assembled_analyzer_top is
  port (
    reset : in std_logic;
	 c0 : in std_logic;
	 c1 : in std_logic;
    DataStrobe_out : out std_logic;
    dataout : out std_logic_vector(7 downto 0);
    ADC_SigIn : in std_logic_vector(9 downto 0);
    Gain_s : out std_logic;--F13
    OutputBusSelect_s : out std_logic;--F15
    Standby_s : out std_logic;--F16
    PowerDown_s : out std_logic;--D16
    OffsetCorrect_s : out std_logic;--P1
    OutputFormat_s : out std_logic--L2
  );
end entity Assembled_analyzer_top;


architecture rtl2 of Assembled_analyzer_top is
 

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
    Clk : in std_logic;
    nRst : in std_logic;
    ReceiveDataMode : in std_logic;
    DataStrobe : in std_logic;
    ISig_In : in std_logic_vector(9 downto 0);
    QSig_In : in std_logic_vector(9 downto 0);
    FS_IncrDecr : in std_logic_vector(1 downto 0);
    IData_Out : out std_logic_vector(9 downto 0);
    QData_Out : out std_logic_vector(9 downto 0);
    DataValid : out std_logic
  );
  end component;



  component MA
    port (
    i_clk : in std_logic;
    i_nRst : in std_logic;
    IData_In : in std_logic_vector(10-1 downto 0);
    QData_In : in std_logic_vector(10-1 downto 0);
    MANumber : in std_logic_vector(5-1 downto 0);
    IData_Out : out std_logic_vector(10-1 downto 0);
    QData_out : out std_logic_vector(10-1 downto 0)
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
    delay : out STD_LOGIC_VECTOR(4 downto 0);
    dataout : out std_logic_vector(7 downto 0)
  );
end component;


--dds
signal clk : std_logic;
signal nRst : std_logic;
signal WB_Addr : std_logic_vector(15 downto 0);
signal WB_DataOut : std_logic_vector(15 downto 0);
signal WB_DataIn : std_logic_vector(15 downto 0);
signal WB_WE : std_logic;
signal WB_Sel : std_logic_vector(1 downto 0);
signal WB_STB : std_logic;
signal WB_Cyc : std_logic;
signal WB_Ack : std_logic;
signal WB_CTI : std_logic_vector(2 downto 0);
signal DataFlow_Clk : std_logic;
signal ADC_Clk : std_logic;

--demodulator
-- signal clk : std_logic;
-- signal nRst : std_logic;
signal IData_In : STD_LOGIC_VECTOR(9 downto 0);
signal QData_In : STD_LOGIC_VECTOR(9 downto 0);
signal DataValid : std_logic;
signal DataStrobe : std_logic;
signal delay : STD_LOGIC_VECTOR(4 downto 0);
-- signal dataout : std_logic_vector(7 downto 0);


--demultiplexer
signal Clk_ADC : std_logic;
signal Clk_DataFlow : std_logic;
-- signal nRst : std_logic;
signal ReceiveDataMode : std_logic;
-- signal ADC_SigIn : std_logic_vector(9 downto 0);
signal ISigOut : std_logic_vector(9 downto 0);
signal QSigOut : std_logic_vector(9 downto 0);
-- signal DataStrobe : std_logic;
-- signal Gain_s : std_logic;
-- signal OutputBusSelect_s : std_logic;
-- signal Standby_s : std_logic;
-- signal PowerDown_s : std_logic;
-- signal OffsetCorrect_s : std_logic;
-- signal OutputFormat_s : std_logic;

--geterodine
-- signal Clk : std_logic;
-- signal nRst : std_logic;
-- signal ReceiveDataMode : std_logic;
-- signal DataStrobe : std_logic;
signal ISig_In : std_logic_vector(9 downto 0);
signal QSig_In : std_logic_vector(9 downto 0);
signal FS_IncrDecr : std_logic_vector(1 downto 0);
signal IData_Out : std_logic_vector(9 downto 0);
signal QData_Out : std_logic_vector(9 downto 0);
-- signal DataValid : std_logic;

--ma
-- signal Clk : std_logic;
-- signal nRst : std_logic;
-- signal ReceiveDataMode : std_logic;
-- signal DataStrobe : std_logic;
-- signal ISig_In : std_logic_vector(9 downto 0);
-- signal QSig_In : std_logic_vector(9 downto 0);
-- signal FS_IncrDecr : std_logic_vector(1 downto 0);
-- signal IData_Out : std_logic_vector(9 downto 0);
-- signal QData_Out : std_logic_vector(9 downto 0);
-- signal DataValid : std_logic;


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


DDS_inst : DDS
port map (
  clk => c0,
  nRst => reset,
  WB_Addr => WB_Addr,
  WB_DataIn => WB_DataOut,
  WB_DataOut => WB_DataIn_1,
  WB_WE => WB_WE,
  WB_Sel => WB_Sel,
  WB_STB => WB_STB,
  WB_Cyc => WB_Cyc_1,
  WB_Ack => WB_Ack,
  WB_CTI => WB_CTI,
  DataFlow_Clk => Clk_DataFlow,
  ADC_Clk => Clk_ADC
);


demultiplexer_top_inst : demultiplexer_top
port map (
  Clk_ADC => Clk_ADC,
  Clk_DataFlow => Clk_DataFlow,
  nRst => reset,
  ReceiveDataMode => ReceiveDataMode,------пока к земле?
  ADC_SigIn => ADC_SigIn,--на выход
  ISigOut => ISigOut,
  QSigOut => QSigOut,
  DataStrobe => DataStrobe, 
  --на выход
  Gain_s => Gain_s,--
  OutputBusSelect_s => OutputBusSelect_s,--
  Standby_s => Standby_s,--
  PowerDown_s => PowerDown_s,--
  OffsetCorrect_s => OffsetCorrect_s,--
  OutputFormat_s => OutputFormat_s--
);


Geterodine_module_inst : Geterodine_module
  port map (
    Clk => c0,
    nRst => reset,
    ReceiveDataMode => ReceiveDataMode,--пока к земле?
    DataStrobe => DataStrobe,
    ISig_In => ISigOut,
    QSig_In => QSigOut,
    FS_IncrDecr => FS_IncrDecr,--
    IData_Out => IData_Out,
    QData_Out => QData_Out,
    DataValid => DataValid
  );


  MA_inst : MA
  port map (
    i_clk => c0,
    i_nRst => reset,
    IData_In => IData_Out,
    QData_In => QData_Out,
    MANumber => delay,
    IData_Out => IData_In,
    QData_out => QData_In
  );


  demodulator_decoder_top_inst : demodulator_decoder_top
  port map (
    clk => c0,
    nRst => reset,
    IData_In => IData_In,
    QData_In => QData_In,
    DataValid => DataValid,
    DataStrobe => DataStrobe_out,--на выход
    delay => delay,
    dataout => dataout--на выход
  );


end architecture;