-- mod-shift-return      launch a term
-- mod-p                 launch dmenu
-- mod-space             cycle through available layout algorithms
-- mod-c                 kill a client window
-- mod-j                 move focus to the next window (also mod-tab)
-- mod-k                 move focus to the previous window
-- mod-return            swap current window, with window in master pane
-- mod-shift-j           swap current window with its next neighbour
-- mod-shift-k           swap current window with its previous neighbour
-- mod-h                 shrink the size of the master pane
-- mod-l                 grow the size of the master pane
-- mod-comma             move clients into the master pane
-- mod-period            move clients out of the master pane
-- mod-q                 dynamically reload xmonad, with a new configuration
-- mod-shift-q           quit xmonad
-- mod-1..9              move to workspace number 'n'
-- mod-shift-1..9        move current client to workspace number 'n'
-- mod-w,e,r             move to Xinerama screens 1, 2 or 3.
-- mod-r                 launch gmrun
import System.IO

import qualified XMonad.StackSet as W

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Actions.CopyWindow
import XMonad.Actions.SpawnOn

-- post-launch hooks
--
-- to get the className: xprop | grep WM_CLASS
-- to get the title:     xprop | grep WM_NAME
myManageHook :: ManageHook
myManageHook = composeAll [
    -- float these
    className =? "VBoxSDL"               --> doFloat,
    className =? "Gimp"                  --> doFloat,
    className =? "Vlc"                   --> doFullFloat,
    className =? "Vncviewer"             --> doFloat,
    -- move these to specific workplaces
    className =? "Xfe"                   --> doF (W.shift "3"),
    className =? "Mysql-workbench-bin"   --> doF (W.shift "4"),
    className =? "Pgadmin3"              --> doF (W.shift "5"),
    className =? "Thunderbird"           --> doF (W.shift "6"),
    className =? "VirtualBox"            --> doF (W.shift "7"),
    className =? "Gimp"                  --> doF (W.shift "9"),
    -- don't launch these in the master pane
    title =? "Downloads"                 --> doF W.swapDown,
    title =? "xterm"                     --> doF W.swapDown,
    className =? "Pidgin"                --> doF W.swapDown,
    -- show this one on all workplaces
    className =? "Xfce4-notifyd"         --> doF W.focusDown <+> doF copyToAll
    ]

-- specific terminal command
myTerminal = "xterm -fa 'Source Code Pro' -fs 11 -cr red1 -selbg grey30"

-- key bindings
myKeys = [
    -- take screenshots
    ((controlMask, xK_Print), spawn "scrot -s"),
    ((0, xK_Print), spawn "scrot"),
    -- specific launch shortcuts
    ((mod4Mask .|. shiftMask, xK_f), spawn "firefox -P default"),
    ((mod4Mask .|. shiftMask, xK_e), spawn (myTerminal ++ 
      " -e /bin/zsh -i -c 'vim --servername PRIMARY'")),
    ((mod4Mask .|. shiftMask, xK_m), spawn "mysql-workbench"),
    ((mod4Mask .|. shiftMask, xK_d), spawn "gthumb"),
    ((mod4Mask .|. shiftMask, xK_equal), spawn "xzoom -mag 10"),
    -- listen to specific hardware buttons
    ((0, 0x1008FF11), spawn "amixer set Master 2-"),
    ((0, 0x1008FF13), spawn "amixer set Master 2+"),
    ((0, 0x1008FF12), spawn "amixer -D pulse set Master toggle"),
    -- kill and copy windows
    ((mod4Mask .|. shiftMask, xK_c), kill1),
    ((mod4Mask, xK_v), windows copyToAll),
    ((mod4Mask .|. shiftMask, xK_v),  killAllOtherCopies),
    ((mod4Mask, xK_c), kill)]
    ++
    [ ((m .|. 0, k), windows $ f i)
    | (i, k) <- zip (myWorkspaces) [xK_F1 .. xK_F9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

-- layout
myLayout = gaps [(U,15)] (smartBorders (tiled ||| Full))
  where
     -- tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     -- number of windows in the master pane
     nmaster = 1
     -- proportion of screen occupied by master pane
     ratio   = toRational (2/(1+sqrt(5)::Double)) -- golden
     -- fraction of screen to increment by when resizing panes
     delta   = 3/100

-- workspace names
myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

-- startup hook
myStartup :: X ()
myStartup = do
    setWMName "LG3D"
    spawnOn "1" "firefox"
    spawnOn "1" myTerminal

main = do
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
    xmonad $ defaultConfig {
        terminal          = myTerminal,
        workspaces        = myWorkspaces,
        focusFollowsMouse = True,
        borderWidth       = 1,
        manageHook        = manageDocks <+> myManageHook <+>
                            manageHook defaultConfig,
        layoutHook        = myLayout,
        startupHook       = myStartup,
        logHook           = dynamicLogWithPP $ xmobarPP {
                              ppOutput = hPutStrLn xmproc
                            , ppTitle = xmobarColor "white" "" . shorten 100
                            },
        modMask = mod4Mask     -- Rebind Mod to the Windows key
     } `additionalKeys`
     myKeys
