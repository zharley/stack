-- RefreshRate is in 1/10 seconds
Config { 
       -- name of the font to be used
       font = "-Misc-Fixed-Bold-R-Normal--13-120-75-75-C-70-ISO8859-1"
       -- background color
       , bgColor = "black"
       -- foreground color
       , fgColor = "grey"
       -- screen position
       , position = Top
       -- send xmobar to the bottom of window stack
       , lowerOnStart = True
       -- programs to run 
       , commands = [ Run Network "eth0" ["-L","0","-H","32","--normal","green","--high","red","-t","<rx> <tx>"] 5
                    , Run Network "wlan0" ["-L","0","-H","32","--normal","green","--high","red","-t","<rx> <tx>"] 5
                    , Run Cpu ["-b", ".", "-f", "*", "-L","3","-H","50","--normal","green","--high","red","-t","<bar>"] 5
                    , Run TopProc ["-L","3","-H","30","--normal","green","--high","red","-t","<name1>"] 5
                    , Run Memory ["-t","<usedratio>%"] 5
                    , Run Swap ["-t","<usedratio>%"] 5
                    , Run Date "%a %d-%b-%Y %l:%M:%S%p" "date" 10
                    , Run StdinReader
                    , Run Com "if ping -c 1 8.8.8.8 > /dev/null; then echo '<fc=#3CB371>ok</fc>'; else echo '<fc=#FF8C00>no</fc>'; fi" [""] "status" 20
                    , Run Com "acpi | awk '{ print $4 $5 }' | sed 's/,/ /'" [""] "batt" 50 
                    ]
       -- character to be used for indicating commands in the output template
       , sepChar = "%"
       -- 2-character alignment string, e.g. LEFT-ALIGNED } CENTERED { RIGHT-ALIGNED
       , alignSep = "}{"
       -- output template
       -- StdinReader - Displays any text received by xmobar on its standard input.
       , template = "%StdinReader% }{ %batt% <fc=#808080>|</fc> %eth0% <fc=#808080>|</fc> %wlan0% <fc=#808080>|</fc> %cpu% <fc=#808080>|</fc> %memory% <fc=#808080>|</fc> <fc=#DAA520>%date%</fc> <fc=#808080>|</fc> %status%"
      }
