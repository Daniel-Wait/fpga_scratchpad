library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 

entity brevia2 is
	port(
		clk_out	: 	inout	std_logic;
		switch 	: 	in 		std_logic_vector(7 downto 0);
		led		:  	out 	std_logic_vector(7 downto 0)
	);
end brevia2;

architecture scratch of brevia2 is
	signal holdin : boolean := false;
	signal cnt_press : integer := 0;
	signal clk_osc : std_logic;
	signal clk_pll_op : std_logic;
	signal clk_pll_os : std_logic;
	signal clk_pll_ok : std_logic;
	
	COMPONENT OSCE
	-- synthesis translate_off
		GENERIC (NOM_FREQ: string := "2.5");
	-- synthesis translate_on
		PORT (OSC:OUT std_logic);
	END COMPONENT;
	
	attribute NOM_FREQ : string;
	attribute NOM_FREQ of OSCinst0 : label is "10";
	
	component mypll
		port (CLK: in std_logic; CLKOP: out std_logic; CLKOS: out std_logic; 
			CLKOK: out std_logic; LOCK: out std_logic);
	end component;
	signal locked : std_logic := '0';
begin	
	with holdin select
		led(6 downto 0) <= "1111111" when true, "0000000" when false;
	with cnt_press select
		clk_out <= clk_osc when 0, clk_pll_op when 1, clk_pll_ok when 2, clk_pll_os when 3, clk_osc when others;
	
	led(7) <= locked;
	
	process(switch(3))
	begin
		if switch(3)'event and switch(3) = '0' then
			holdin <= not holdin;
			cnt_press <= (cnt_press + 1) mod 4;
		end if;
	end process;
	
	OSCinst0 : OSCE
	-- synthesis translate_off
		generic map (NOM_FREQ => NOM_FREQ);
	-- synthesis translate_on
		port map (OSC => clk_osc);
		
	PLLinst0 : mypll
		port map(CLK=>clk_osc, CLKOP=>clk_pll_op, CLKOS => clk_pll_os, CLKOK => clk_pll_ok, LOCK=>locked);
end scratch;