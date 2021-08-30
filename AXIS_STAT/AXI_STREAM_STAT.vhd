--! @title AXI_STREAM_STAT
--! @file top_level.vhd
--! @author Joseph Pierce Vincent (josephpiercevincent@gmail.com)
--! @version 0.1
--! @date 2021-08-28
--!
--! @brief This module will monitor and ouput the number of bursts
--! in a packet on the AXIS master bus attached to the slave port 
--! of this module.

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity AXIS_STAT is
  Port ( 
      
    SAXIS_ACLK : in STD_LOGIC; --! AXIS Bus Clock 
    SAXIS_TDATA : in STD_LOGIC_VECTOR(31 downto 0); --! AXIS Data lane
    SAXIS_TREADY : out STD_LOGIC; --! AXIS TREADY signal (always high indicating the module is always ready to receive data)
    SAXIS_TVALID : in STD_LOGIC; --! AXIS TVALID signal which indicated incomind data is valid
    SAXIS_TLAST : in STD_LOGIC; --! AXIS TLAST signal which indicates the end of an AXIS packet
    SAXIS_RESETN : in STD_LOGIC; --! Synchronous reset port
    NUM_BURSTS : out STD_LOGIC_VECTOR(15 downto 0) --! Output statistic. The number of bursts in an entire transaction (How many TDATA datawords came in before the last TLAST)
  );
end AXIS_STAT;

architecture Behavioral of AXIS_STAT is

signal tdata_r : STD_LOGIC_VECTOR(31 downto 0); --! register for incoming data to keep this port after a synthesis


begin


count_dataWords: process(SAXIS_ACLK, SAXIS_RESETN, SAXIS_TLAST, SAXIS_TVALID)
VARIABLE numBursts_i : INTEGER range 0 to 65535 := 0;
begin
    if rising_edge(SAXIS_ACLK) then
        if SAXIS_RESETN = '0' then
            tdata_r <= (others => '0');
            numBursts_i := 0;
        elsif SAXIS_TLAST = '1' then
        
            NUM_BURSTS <= STD_LOGIC_VECTOR(to_unsigned(numBursts_i, 16));
            numBursts_i := 0;   
        
        elsif SAXIS_TVALID = '1' then 
            tdata_r  <= SAXIS_TDATA;
            numBursts_i := numBursts_i + 1;
        
        end if;

    end if;


end process;

SAXIS_TREADY <= '1';

end Behavioral;