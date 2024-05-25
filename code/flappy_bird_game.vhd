LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.game_type_pkg.ALL;

ENTITY flappy_bird_game IS
    PORT (
        clk, reset_signal, vert_sync, collision, reset_pipes, reset_blue_box : IN STD_LOGIC;
        sw9, pb1, pb2, pb3, left_click : IN STD_LOGIC;
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        output_on : OUT STD_LOGIC;
        RGB : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        hund_bcd, tens_bcd, units_bcd : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        Red, Green, Blue : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF flappy_bird_game IS
    SIGNAL state_in, state_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL ball_x_pos, ball_y_pos : SIGNED(10 DOWNTO 0);
    SIGNAL ball_size : SIGNED(9 DOWNTO 0) := to_signed(16, 10);
    SIGNAL p1_x_pos, p2_x_pos, p3_x_pos : SIGNED(10 DOWNTO 0);
    SIGNAL p1_gap_center, p2_gap_center, p3_gap_center : SIGNED(9 DOWNTO 0);
    SIGNAL blue_box_x_pos : SIGNED(10 DOWNTO 0);
    SIGNAL blue_box_y_pos : SIGNED(9 DOWNTO 0);
    SIGNAL pause_signal : STD_LOGIC;
    SIGNAL bouncy_ball_output_on, pipes_output_on, ground_output_on, background_output_on, text_on : STD_LOGIC;
    SIGNAL bouncy_ball_RGB, pipes_RGB, ground_RGB, background_RGB, text_RGB : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL score_internal : INTEGER RANGE 0 TO 999;

    -- Signals for bouncy_ball component
    SIGNAL ball_collision : STD_LOGIC;
    SIGNAL ball_reset_signal : STD_LOGIC;
    SIGNAL ball_reset_blue_box : STD_LOGIC;

    COMPONENT Game_FSM IS
        PORT(
            sw9, pb1, pb2, pb3, left_click : IN STD_LOGIC;
            state_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input state
            state_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output state
        );
    END COMPONENT Game_FSM;
    
    COMPONENT text_rom IS 
        PORT (
            pixel_row, pixel_col : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clk, collision, left_click : IN STD_LOGIC;
            input_state : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- Input state from FSM
            score : IN integer range 0 to 999;
            output_on : OUT STD_LOGIC;
            RGB : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT text_rom;
    
    COMPONENT bouncy_ball IS
        PORT (
            sw9, pb1, clk, vert_sync, left_click: IN std_logic;
            pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
            input_state : IN std_logic_vector(3 DOWNTO 0); -- Input state for FSM
            output_state : OUT std_logic_vector(3 DOWNTO 0); -- Output state for FSM
            p1_x_pos, p2_x_pos, p3_x_pos : IN signed(10 DOWNTO 0);
            p1_gap_center, p2_gap_center, p3_gap_center : IN signed(9 DOWNTO 0);
            blue_box_x_pos: IN signed(10 DOWNTO 0);
            blue_box_y_pos : IN signed(9 DOWNTO 0);
            output_on, start_signal, collision, reset_signal, reset_blue_box: OUT std_logic;
            score : OUT integer range 0 to 999;
            hund_bcd, tens_bcd, units_bcd : OUT std_logic_vector(3 DOWNTO 0);
            RGB : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT bouncy_ball;
    
    COMPONENT pipes IS
        PORT (
            clk, vert_sync, reset_signal, collision, reset_pipes: IN std_logic;
            pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
            input_state : IN std_logic_vector(3 DOWNTO 0); -- Input state for FSM
            output_on : OUT std_logic;
            RGB : OUT std_logic_vector(11 DOWNTO 0);
            p1_x_pos, p2_x_pos, p3_x_pos : OUT signed(10 DOWNTO 0);
            p1_gap_center, p2_gap_center, p3_gap_center : OUT signed(9 DOWNTO 0);
            blue_box_x_pos : OUT signed(10 DOWNTO 0);
            blue_box_y_pos : OUT signed(9 DOWNTO 0);
            reset_blue_box : IN std_logic;
            ball_x_pos, ball_y_pos : IN signed(10 DOWNTO 0); -- Add ball position inputs
            ball_size : IN signed(9 DOWNTO 0) -- Add ball size input
        );
    END COMPONENT pipes;
    
    COMPONENT ground IS
        PORT (
            clk, vert_sync, left_click, collision, reset, pause: IN std_logic;
            pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
            output_on : OUT std_logic;
            RGB : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT ground;
    
    COMPONENT background IS
        PORT (
            pixel_row, pixel_column    : IN std_logic_vector(9 DOWNTO 0);
            pb1, clk, vert_sync, left_click, collision, reset : IN std_logic;
            output_on                  : OUT std_logic;
            RGB                        : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT background;

    BEGIN
     
    FSM : Game_FSM 
        PORT MAP (
            sw9 => sw9,
            pb1 => pb1,
            pb2 => pb2,
            pb3 => pb3,
            left_click => left_click,
            state_in => state_in,
            state_out => state_out
        );
    
    BALL_Inst : bouncy_ball
        PORT MAP (
            sw9 => sw9,
            pb1 => pb1,
            clk => clk,
            vert_sync => vert_sync,
            left_click => left_click,
            pixel_row => pixel_row,
            pixel_column => pixel_column,
            input_state => state_out,
            p1_x_pos => p1_x_pos,
            p2_x_pos => p2_x_pos,
            p3_x_pos => p3_x_pos,
            p1_gap_center => p1_gap_center,
            p2_gap_center => p2_gap_center,
            p3_gap_center => p3_gap_center,
            blue_box_x_pos => blue_box_x_pos,
            blue_box_y_pos => blue_box_y_pos,
            output_state => state_in,
            output_on => bouncy_ball_output_on,
            start_signal => open,
            collision => ball_collision,
            reset_signal => ball_reset_signal,
            reset_blue_box => ball_reset_blue_box,
            score => score_internal,
            hund_bcd => hund_bcd,
            tens_bcd => tens_bcd,
            units_bcd => units_bcd,
            RGB => bouncy_ball_RGB
        );

    PIPES_Inst : pipes
        PORT MAP (
            clk => clk,
            vert_sync => vert_sync,
            reset_signal => reset_signal,
            collision => collision,
            reset_pipes => reset_pipes,
            pixel_row => pixel_row,
            pixel_column => pixel_column,
            input_state => state_out,
            output_on => pipes_output_on,
            RGB => pipes_RGB,
            p1_x_pos => p1_x_pos,
            p2_x_pos => p2_x_pos,
            p3_x_pos => p3_x_pos,
            p1_gap_center => p1_gap_center,
            p2_gap_center => p2_gap_center,
            p3_gap_center => p3_gap_center,
            blue_box_x_pos => blue_box_x_pos,
            blue_box_y_pos => blue_box_y_pos,
            reset_blue_box => reset_blue_box,
            ball_x_pos => ball_x_pos,
            ball_y_pos => ball_y_pos,
            ball_size => ball_size
        );

    GROUND_Inst : ground
        PORT MAP (
            clk => clk,
            vert_sync => vert_sync,
            left_click => left_click,
            collision => collision,
            reset => reset_signal,
            pause => pause_signal,
            pixel_row => pixel_row,
            pixel_column => pixel_column,
            output_on => ground_output_on,
            RGB => ground_RGB
        );

    BACKGROUND_Inst : background
        PORT MAP (
            pixel_row => pixel_row,
            pixel_column => pixel_column,
            pb1 => pb1,
            clk => clk,
            vert_sync => vert_sync,
            left_click => left_click,
            collision => collision,
            reset => reset_signal,
            output_on => background_output_on,
            RGB => background_RGB
        );

    TEXT_ROM_Inst : text_rom
        PORT MAP (
            pixel_row => pixel_row,
            pixel_col => pixel_column,
            clk => clk,
            collision => collision,
            left_click => left_click,
            input_state => state_out,
            score => score_internal,
            output_on => text_on,
            RGB => text_RGB
        );

    output_on <= bouncy_ball_output_on OR pipes_output_on OR ground_output_on OR background_output_on OR text_on;

    PROCESS (pipes_output_on, bouncy_ball_output_on, background_output_on, text_on, ground_output_on, pipes_RGB, bouncy_ball_RGB, background_RGB, ground_RGB, text_RGB)
        variable red_signal, green_signal, blue_signal : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        IF text_on = '1' THEN
            red_signal := "1111";
            green_signal := "1111";
            blue_signal := "1111";
        ELSIF bouncy_ball_output_on = '1' THEN
            red_signal := bouncy_ball_RGB(11 DOWNTO 8);
            green_signal := bouncy_ball_RGB(7 DOWNTO 4);
            blue_signal := bouncy_ball_RGB(3 DOWNTO 0);
        ELSIF ground_output_on = '1' THEN
            red_signal := ground_RGB(11 DOWNTO 8);
            green_signal := ground_RGB(7 DOWNTO 4);
            blue_signal := ground_RGB(3 DOWNTO 0);
        ELSIF pipes_output_on = '1' THEN
            red_signal := pipes_RGB(11 DOWNTO 8);
            green_signal := pipes_RGB(7 DOWNTO 4);
            blue_signal := pipes_RGB(3 DOWNTO 0);
        ELSE
            red_signal := background_RGB(11 DOWNTO 8);
            green_signal := background_RGB(7 DOWNTO 4);
            blue_signal := background_RGB(3 DOWNTO 0);
        END IF;
        Red <= red_signal;
        Green <= green_signal;
        Blue <= blue_signal;
    END PROCESS;
END ARCHITECTURE;
