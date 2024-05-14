library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- Prefer this over STD_LOGIC_ARITH and STD_LOGIC_UNSIGNED

ENTITY VGA_SYNC IS
    PORT(
        clock_25Mhz                  : IN  STD_LOGIC;
        red, green, blue             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        horiz_sync_out, vert_sync_out: OUT STD_LOGIC;
        pixel_row, pixel_column      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END VGA_SYNC;

ARCHITECTURE a OF VGA_SYNC IS
    SIGNAL horiz_sync, vert_sync      : STD_LOGIC;
    SIGNAL video_on, video_on_v, video_on_h : STD_LOGIC;
    SIGNAL h_count, v_count           : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

-- video_on is high only when RGB data is displayed
video_on <= video_on_h AND video_on_v;

PROCESS(clock_25Mhz)
BEGIN
    IF rising_edge(clock_25Mhz) THEN
        -- Horizontal and Vertical Sync Logic as previously described
        -- H_count and V_count logic remains unchanged

        -- Output 4-bit color data only when within visible region and video_on is high
        IF video_on = '1' THEN
            red_out <= red;
            green_out <= green;
            blue_out <= blue;
        ELSE
            red_out <= (others => '0');
            green_out <= (others => '0');
            blue_out <= (others => '0');
        END IF;

        horiz_sync_out <= horiz_sync;
        vert_sync_out <= vert_sync;
    END IF;
END PROCESS;

END a;
