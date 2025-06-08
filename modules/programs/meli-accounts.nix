pkgs:
{ config, lib, ... }:

with lib;

let
  tomlFormat = pkgs.formats.toml { };
in
{
  options.meli = {
    enable = mkEnableOption "meli";

    # listing.index_style = "compact"
    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      # example = literalExpression ''
      #   {
    };

  };

  config = mkIf config.meli.enable {
    # alot.sendMailCommand = mkOptionDefault (if config.msmtp.enable then
    #   "msmtpq --read-envelope-from --read-recipients"
    # else
    #   null);
  };
}
