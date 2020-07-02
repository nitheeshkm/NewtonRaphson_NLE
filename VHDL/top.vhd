----------------------------------------------------------------------------------
-- Company: URTPC
-- Engineer: Nitheesh Manjunath
-- 
-- Create Date: 06/18/2020 02:05:55 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
    Generic(
        dw : natural  := 32
--        row : natural := 3;
--        col : natural := 3  
    );
    Port ( 
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        xo : in std_logic_vector(dw-1 downto 0);
        yo : in std_logic_vector(dw-1 downto 0);
        zo : in std_logic_vector(dw-1 downto 0);
        iter : in std_logic_vector(4-1 downto 0);
        
        xn : out std_logic_vector(dw-1 downto 0);
        yn : out std_logic_vector(dw-1 downto 0);
        zn : out std_logic_vector(dw-1 downto 0);
        rootsFound : out std_logic
    );
end top;

architecture Behavioral of top is
    type state_type is (state_0, state_1, state_2, state_3, state_4, state_5, state_6); 
    signal currentState : state_type;
    
    signal iter_cnt : std_logic_vector(5-1 downto 0) := (others => '0');
    signal col_cnt : std_logic_vector(5-1 downto 0) := (others => '0');
    signal row_cnt : std_logic_vector(5-1 downto 0) := (others => '0');
    
    signal iAj_address : std_logic_vector(10-1 downto 0) := (others => '0');
    signal F_address : std_logic_vector(5-1 downto 0) := (others => '0');
    signal IF_Address : std_logic_vector(5-1 downto 0) := (others => '0');
    
    signal en : std_logic := '0';
    signal newMac : std_logic := '0';
    signal newMac_1 : std_logic := '0';
    signal Inv_J_rst : std_logic := '0';
    
    signal Inv_J_rst_1 : std_logic := '0';
    
    signal done : std_logic := '0';
    signal macDone : std_logic := '0';
    
    signal x : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal y : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal z : std_logic_vector(dw-1 downto 0) := (others => '0');
    
    type memory_0 is array(0 to 2) of std_logic_vector(dw-1 downto 0);
    signal F : memory_0;
    
    type memory_1 is array(0 to 8) of std_logic_vector(2*dw-1 downto 0);
    signal iAj : memory_1;
    
    type memory_2 is array(0 to 2) of std_logic_vector(dw-1 downto 0);
    signal IFBuffer : memory_2;
    
    
        
    signal Aj00 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj01 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj02 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj10 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj11 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj12 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj20 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj21 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal Aj22 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal D : std_logic_vector(dw-1 downto 0) := (others => '0');
    
    signal x_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal x2 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal y_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal z_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal xy_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal y3 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal yz : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal xy : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal xz_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal yz_sq : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal z3 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    
    signal A : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal B : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal P : std_logic_vector(dw-1 downto 0) := (others => '0');
begin

Inv_J : entity work.Inverse_Jacob 
    generic map
    (
    dw => dw
    )
    port map(
        clk,
        Inv_J_rst_1,
        en, 
        x, 
        y, 
        z, 
        
        done, 
        D, 
        Aj00, 
        Aj10, 
        Aj20, 
        Aj01, 
        Aj11, 
        Aj21, 
        Aj02, 
        Aj12, 
        Aj22
        );

MAC_mod : entity work.MAC 
    generic map
    (
    dw,
    dw
    )
    port map(
        clk,
        rst,
        newMac_1,
        A,
        B,
        P,
        macDone
        );



--process(clk) begin
--    if rising_edge(clk) then
--        if rst = '1' then
--        else 
--        end if;
--    end if;
--end process;

Inv_J_rst_1 <= rst or Inv_J_rst; 

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            currentState <= state_0;
            en <= '0';
            x <= (others => '0');
            y <= (others => '0');
            z <= (others => '0');
            iter_cnt <= (others => '0');
            col_cnt <= (others => '0');
            row_cnt <= (others => '0');
            newMac <=  '0';
            rootsFound <= '0';
            Inv_J_rst <= '0';
        else
            case (currentState) is
                when state_0 =>
                    iter_cnt <= (others => '0');
                    col_cnt <= (others => '0');
                    row_cnt <= (others => '0');
                    newMac <= '0';
                    Inv_J_rst <= '0';
                    rootsFound <= '0';
                    if start = '1' then
                        currentState <= state_1;
                        en <= '1';
                        x <= xo;
                        y <= yo;
                        z <= zo;
                    else 
                        currentState <= state_0;
                        en <= '0';
                        x <= (others => '0');
                        y <= (others => '0');
                        z <= (others => '0');
                    end if;
                
                when state_1 =>
                    en <= '0';
                    if done = '1' then
                        iter_cnt <= std_logic_vector(unsigned(iter_cnt) + "1");
                        currentState <= state_2;
                    else 
                        currentState <= state_1;
                    end if;
                
                when state_2 => 
                    currentState <= state_3;
                    newMac <= '1';
                
                when state_3 => 
                    if unsigned(col_cnt) < 3-1 then
                        col_cnt <= std_logic_vector(unsigned(col_cnt) + "1");
                        newMac <= '0';
                    else
                        if unsigned(row_cnt) < 3-1  then
                            row_cnt <= std_logic_vector(unsigned(row_cnt) + "1");
                            col_cnt <= (others => '0');
                            newMac <= '1';
                        else 
                            currentState <= state_4; 
                            col_cnt <= (others => '0');
                            row_cnt <= (others => '0');
                            newMac <= '0';
                        end if;
                    end if;
                
                when state_4 =>
                    if macDone = '1' then
                        currentState <= state_5;
                        Inv_J_rst <= '1'; 
                    else 
                        currentState <= state_4;
                    end if;
                
                when state_5 => 
                    x <= std_logic_vector(signed(x) - signed(IFBuffer(0)));
                    y <= std_logic_vector(signed(y) - signed(IFBuffer(1)));
                    z <= std_logic_vector(signed(z) - signed(IFBuffer(2)));
                    if unsigned(iter_cnt) < unsigned(iter) then 
                        currentState <= state_1;
                        en <= '1';
                        Inv_J_rst <= '0';
                    else
                        currentState <= state_6;
                        en <= '0';
                        Inv_J_rst <= '0';
                    end if;
                    
                when state_6 =>
                    currentState <= state_0;
                    rootsFound <= '1';
                    Inv_J_rst <= '0';
                    
                when others =>
                    currentState <= state_0;
                    
            end case;
        end if;
    end if;
end process;


process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            F(0) <= (others => '0');
            F(1) <= (others => '0');
            F(2) <= (others => '0');
        else
            F(0) <= std_logic_vector(signed(x_sq(56-1 downto 24)) - signed(x2(56-1 downto 24)) + signed(y_sq(56-1 downto 24)) - signed(z) + "00000001000000000000000000000000");
            F(1) <= std_logic_vector(signed(xy_sq(56-1 downto 24)) - signed(x) - signed(y3(56-1 downto 24)) + signed(yz(56-1 downto 24)) + "00000010000000000000000000000000");
            F(2) <= std_logic_vector(signed(xz_sq(56-1 downto 24)) - signed(z3(56-1 downto 24)) + signed(yz_sq(56-1 downto 24)) + signed(xy(56-1 downto 24)));
        end if;
    end if;
end process;

x2 <= std_logic_vector("00000010000000000000000000000000"*signed(x));
x_sq <= std_logic_vector(signed(x)*signed(x));
y_sq <= std_logic_vector(signed(y)*signed(y));
z_sq <= std_logic_vector(signed(z)*signed(z));
xy_sq <= std_logic_vector(signed(x)*signed(y_sq(56-1 downto 24)));
y3 <= std_logic_vector("00000011000000000000000000000000" * signed(y));
yz <= std_logic_vector(signed(y)*signed(z));
xy <= std_logic_vector(signed(x)*signed(y));
xz_sq <= std_logic_vector(signed(z_sq(56-1 downto 24))*signed(x));
yz_sq <= std_logic_vector(signed(z_sq(56-1 downto 24))*signed(y));
z3 <= std_logic_vector("00000011000000000000000000000000" * signed(z));

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            iAj(0) <= (others => '0');
            iAj(1) <= (others => '0');
            iAj(2) <= (others => '0');
            iAj(3) <= (others => '0');
            iAj(4) <= (others => '0');
            iAj(5) <= (others => '0');
            iAj(6) <= (others => '0');
            iAj(7) <= (others => '0');
            iAj(8) <= (others => '0');
        else
            if currentState = state_2 then
                iAj(0) <= std_logic_vector(signed(Aj00)*signed(D));
                iAj(1) <= std_logic_vector(signed(Aj10)*signed(D));
                iAj(2) <= std_logic_vector(signed(Aj20)*signed(D));
                iAj(3) <= std_logic_vector(signed(Aj01)*signed(D)); 
                iAj(4) <= std_logic_vector(signed(Aj11)*signed(D));
                iAj(5) <= std_logic_vector(signed(Aj21)*signed(D));
                iAj(6) <= std_logic_vector(signed(Aj02)*signed(D));
                iAj(7) <= std_logic_vector(signed(Aj12)*signed(D));
                iAj(8) <= std_logic_vector(signed(Aj22)*signed(D));
            end if;
        end if;
    end if;
end process;


process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            iAj_address <= (others => '0');
            F_address <= (others => '0');
            newMac_1 <= '0';
        else 
            if currentState = state_3 then
                iAj_address <= std_logic_vector(unsigned(col_cnt) + unsigned(row_cnt) * 3);
                F_address <= col_cnt;
                newMac_1 <= newMac;
            end if;
        end if;
    end if;
end process;


A <= iAj(to_integer(unsigned(iAj_address)))(56-1 downto 24);
B <= F(to_integer(unsigned(F_address)));

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' or currentState = state_1 then
            IFBuffer(0) <= (others => '0');
            IFBuffer(1) <= (others => '0');
            IFBuffer(2) <= (others => '0');
            IF_Address <= (others => '0');
        else
            if macDone = '1' then
                IFBuffer(to_integer(unsigned(IF_Address))) <= P;
                IF_Address <= std_logic_vector(unsigned(IF_Address) + 1);
            end if;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            xn <= (others => '0');
            yn <= (others => '0');
            zn <= (others => '0');
        else
            xn <= x;
            yn <= y;
            zn <= z;
        end if;
    end if;
end process;

end Behavioral;
