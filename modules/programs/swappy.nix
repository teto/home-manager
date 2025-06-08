{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.swappy;

  iniFormat = pkgs.formats.ini { };

  iniFile = iniFormat.generate "config" cfg.settings;

in
{
  meta.maintainers = [ hm.maintainers.eclairevoyant ];

  options.programs.swappy = {
    enable = mkEnableOption "Swappy";

    package = mkOption {
      type = types.package;
      default = pkgs.swappy;
      defaultText = literalExpression "pkgs.swappy";
      description = "Package providing <command>swappy</command>.";
    };

    settings = mkOption {
      type = iniFormat.type;
      default = {
        Default = {
          save_dir = "$HOME/Desktop";
          save_filename_format = "swappy-%Y%m%d-%H%M%S.png";
          show_panel = false;
          line_size = 5;
          text_size = 20;
          text_font = "sans-serif";
          paint_mode = "brush";
          early_exit = false;
          fill_shape = false;
        };
      };
      example = ''
        {
          Default = {
            show_panel = true;
          };
        }'';
      description = ''
        Configuration to use for Swappy. See
        <citerefentry>
          <refentrytitle>swappy</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        for available options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = mkIf (cfg.settings != { }) { "swappy/config".source = iniFile; };
  };
}
