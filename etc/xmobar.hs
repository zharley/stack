Config { font = "-Misc-Fixed-Bold-R-Normal--13-120-75-75-C-70-ISO8859-1"
       , bgColor = "black"
       , fgColor = "grey"
       , position = TopW L 10000000000 
       , lowerOnStart = True
       , commands = [ Run Network "eth0" ["-L","0","-H","32","--normal","green","--high","red","-t","<rx> <tx>"] 5
                    , Run Network "wlan0" ["-L","0","-H","32","--normal","green","--high","red","-t","<rx> <tx>"] 5
                    , Run Cpu ["-L","3","-H","50","--normal","green","--high","red","-t","<total>"] 10
                    , Run Memory ["-t","<usedratio>%"] 10
                    , Run Swap ["-t","<usedratio>"] 10
                    , Run Date "%a %d-%b-%Y %l:%M%p" "date" 10
                    , Run StdinReader
                    , Run Com "acpi | awk '{ print $4 $5 }' | sed 's/,/ /'" [""] "batt" 10 
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %batt% | %cpu% [%memory%, %swap%] | %eth0% | %wlan0% | <fc=#ee9a00>%date%</fc>"
      }
