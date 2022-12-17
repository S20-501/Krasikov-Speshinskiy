library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity DUT is
    port(
        FT2232H_FSDI : out std_logic;
        FT2322H_FSCLK : out std_logic;
        tester_clk : in std_logic;
        tester_reset : in std_logic;
        FT2232H_FSCTS : in std_logic;
        FT2232H_FSDO : in std_logic
    );
end DUT;


architecture test of DUT is

begin

end test;