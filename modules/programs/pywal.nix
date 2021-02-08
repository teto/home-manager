{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.pywal;

in {
  options = {
    programs.pywal = {
      enable = mkEnableOption "pywal";
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ pkgs.pywal ];

    programs.zsh.initExtra = ''
      # Import colorscheme from 'wal' asynchronously
      # &   # Run the process in the background.
      # ( ) # Hide shell job control messages.
      (cat ~/.cache/wal/sequences &)

      # Alternative (blocks terminal for 0-3ms)
      cat ~/.cache/wal/sequences
    '';

    # https://github.com/DrChef/my-dot-files/blob/e72b950ba8b766ddaa02b4163646c44ddfa7f2c5/config#L23
    xsession.windowManager.i3 = {
      extraConfig = ''
        set_from_resource $bg           i3wm.color0 #ff0000
        set_from_resource $bg-alt       i3wm.color14 #ff0000
        set_from_resource $fg           i3wm.color15 #ff0000
        set_from_resource $fg-alt       i3wm.color2 #ff0000
        set_from_resource $hl           i3wm.color13 #ff0000
      '';

      config.colors = {

        # # class                 border,  backgrd,  text,    indicator,  child border
        # # client.focused          $focused_border $client_bg #FFFF50
        # # client.urgent           #870000 #870000 #ffffff #090e14
        # # client.background       $client_bg
        # # # client.background       #66ff33

        # # client.placeholder  #000000 #0c0c0c #ffffff #000000   #0c0c0c

        #   background = "#d70a53";
        #   # focused_inactive = 
# # class                 border      backgr. text indicator      child_border
# client.focused          $fg-alt     $bg     $hl  $fg-alt        $hl
# client.focused_inactive $fg-alt     $bg     $fg  $fg-alt        $fg-alt
# client.unfocused        $fg-alt     $bg     $fg  $fg-alt        $fg-alt
# client.urgent           $fg-alt     $bg     $fg  $fg-alt        $fg-alt
# client.placeholder      $fg-alt     $bg     $fg  $fg-alt        $fg-alt
# client.background $bg

        # client.focused          $focused_border $client_bg #FFFF50
          focused = {
            border = "$fg-alt";
            background = "$bg";
            text = "$hl";
            indicator = "$fg-alt";
            childBorder = "$hl";
          };
          focusedInactive = {
            border = "$fg-alt";
            background = "$bg";
            text = "$fg";
            indicator = "$fg-alt";
            childBorder = "$fg-alt";
          };

          unfocused = {
            border = "$fg-alt";
            background = "$bg";
            text = "$fg";
            indicator = "$fg-alt";
            childBorder = "$fg-alt";
          };

          urgent = {
            border = "$fg-alt";
            background = "$bg";
            text = "$fg";
            indicator = "$fg-alt";
            childBorder = "$fg-alt";
          };

          background = "$bg";
        };
    };
  };
}

