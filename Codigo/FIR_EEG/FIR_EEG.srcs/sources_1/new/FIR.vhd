----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.09.2024 18:25:47
-- Design Name: 
-- Module Name: FIR - Behavioral
-- Project Name: FIR_TESTING_EEG
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


Library IEEE;  
 USE IEEE.Std_logic_1164.all;   
 USE IEEE.Std_logic_signed.all;   
 -- fpga4student.com: FPGA projects, VHDL projects, Verilog projects   
 -- LOW pass FIR filter for ECG Denoising
 -- VHDL project: VHDL code for FIR filter   
 entity FIR_RI is  -- VHDL projects
 generic (  
           input_width          : integer     :=8               ;-- set input width by user  
           output_width     : integer     :=16               ;-- set output width by user  
           coef_width          : integer     :=8               ;-- set coefficient width by user  
           tap                    : integer     :=11               ;-- set filter order  
           guard               : integer     :=0)               ;-- log2(tap)+1  
 port(  
      Din          : in      std_logic_vector(input_width-1 downto 0)     ;-- input data  
      Clk          : in      std_logic                                             ;-- input clk  
      reset     : in      std_logic                                             ;-- input reset  
      Dout     : out      std_logic_vector(output_width-1 downto 0))     ;-- output data  
 end FIR_RI;  
 architecture behaivioral of FIR_RI is  
 -- N bit Register  
 component N_bit_Reg   
 generic (  
           input_width          : integer     :=8  
           );  
   port(  
    Q : out std_logic_vector(input_width-1 downto 0);     
    Clk :in std_logic;    
    reset :in std_logic;   
    D :in std_logic_vector(input_width-1 downto 0)    
   );  
 end component;
 -- fpga4student.com: FPGA projects, VHDL projects, Verilog projects  
 type Coeficient_type is array (1 to tap) of std_logic_vector(coef_width-1 downto 0);  
 -----------------------------------FIR filter coefficients----------------------------------------------------------------  
 constant coeficient: coeficient_type :=   
                               (     X"F1",  
                                    X"F3",  
                                    X"07",  
                                    X"26",  
                                    X"42",  
                                    X"4E",  
                                    X"42",  
                                    X"26",  
                                    X"07",  
                                    X"F3",  
                                    X"F1"                                     
                                    );                                         
 ----------------------------------------------------------------------------------------------                                     
 type shift_reg_type is array (0 to tap-1) of std_logic_vector(input_width-1 downto 0);  
 signal shift_reg : shift_reg_type;  
 type mult_type is array (0 to tap-1) of std_logic_vector(input_width+coef_width-1 downto 0);  
 signal mult : mult_type;  
 type ADD_type is array (0 to tap-1) of std_logic_vector(input_width+coef_width-1 downto 0);  
 signal ADD: ADD_type;  
 begin  
 -- fpga4student.com: FPGA projects, VHDL projects, Verilog projects
        shift_reg(0)     <= Din;  
           mult(0)<= Din*coeficient(1);  
           ADD(0)<= Din*coeficient(1);  
           GEN_FIR:  
           for i in 0 to tap-2 generate  
           begin  
                 -- N-bit reg unit  
                 N_bit_Reg_unit : N_bit_Reg generic map (input_width => 8)   
                 port map ( Clk => Clk,   
                                    reset => reset,  
                                    D => shift_reg(i),  
                                    Q => shift_reg(i+1)  
                                    );       
                -- filter multiplication  
                mult(i+1)<= shift_reg(i+1)*coeficient(i+2);  
                -- filter conbinational addition  
                ADD(i+1)<=ADD(i)+mult(i+1);  
           end generate GEN_FIR;  
           Dout <= ADD(tap-1);  
 end Architecture;  

 Library IEEE;  
 USE IEEE.Std_logic_1164.all;  
 
 -- fpga4student.com: FPGA projects, VHDL projects, Verilog projects   
 -- LOW pass FIR filter for ECG Denoising
 -- VHDL project: VHDL code for FIR filter
 -- N-bit Register in VHDL 
 entity N_bit_Reg is   
 generic (  
           input_width          : integer     :=8  
           );  
   port(  
    Q : out std_logic_vector(input_width-1 downto 0);    
    Clk :in std_logic;    
    reset :in std_logic;  
    D :in std_logic_vector(input_width-1 downto 0)    
   );  
 end N_bit_Reg;  
  -- fpga4student.com: FPGA projects, VHDL projects, Verilog projects  
 architecture Behavioral of N_bit_Reg is   
 begin   
      process(Clk,reset)  
      begin   
           if (reset = '1') then  
                Q <= (others => '0');  
        elsif ( rising_edge(Clk) ) then  
                Q <= D;   
       end if;      
      end process;   
 end Behavioral;