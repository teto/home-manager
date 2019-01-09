{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.pywal;
  supportedProgram = types.enum [ "neovim" "kitty" "rofi" "i3" "sway" ];

in {
  options = {
    programs.pywal = { enable = mkEnableOption "pywal"; };

    blocklist = mkOption {
      type = types.listOf supportedProgram;
      default = [ ];
      example = literalExpression ''[ "kitty" , "neovim"]'';
      description = ''
        Prevents pywal from being executed for some programs.
      '';
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ pkgs.pywal ];

    programs.zsh.initExtra = ''
      # Import colorscheme from 'wal' asynchronously
      # &   # Run the process in the background.
      # ( ) # Hide shell job control messages.
      (cat ${config.xdg.cacheHome}/wal/sequences &)
    '';

    # TODO check if
    # mkIf "kitty" cfg.blocklist
    programs.kitty.extraConfig = ''
      include ${config.xdg.cacheHome}/wal/colors-kitty.conf
    '';

    programs.rofi.theme."@import" =
      "${config.xdg.cacheHome}/wal/colors-rofi-dark.rasi";

    programs.neovim.plugins = [{
      plugin = pkgs.vimPlugins.pywal-nvim;
      type = "lua";
    }];

    # wal generates and that's the one we should load from /home/teto/.cache/wal/colors.Xresources ~/.Xresources
    xsession.windowManager.i3 = {
      extraConfig = ''
        set_from_resource $bg           i3wm.color0 #ff0000
        set_from_resource $bg-alt       i3wm.color14 #ff0000
        set_from_resource $fg           i3wm.color15 #ff0000
        set_from_resource $fg-alt       i3wm.color2 #ff0000
        set_from_resource $hl           i3wm.color13 #ff0000
      '';

      config.colors = {
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

