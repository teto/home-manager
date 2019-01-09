{ config, lib, ... }:

with lib;

{
  options.neomutt = {
    enable = mkEnableOption "NeoMutt";

      # TODO we need some logic on how to 
      # externalMta = mkOption {
      #   type = types.bool;
      #   default = true;
      #   description = "Use external smtp";
      # };

      externalMra = mkOption {
        type = types.bool;
        default = true;
        description = "Use external fetcher";
      };

    # set new_mail_command = ""
    onNewMailCommand = mkOption {
      type = types.nullOr types.str;
      description = ''
        <command>msmtpq --read-envelope-from --read-recipients</command>.
      '';
    };

    sendMailCommand = mkOption {
      type = types.nullOr types.str;
      default = if config.msmtp.enable then
        "msmtpq --read-envelope-from --read-recipients"
      else
        null;
      defaultText = literalExample ''
        if config.msmtp.enable then
          "msmtpq --read-envelope-from --read-recipients"
        else
          null
      '';
      example = "msmtpq --read-envelope-from --read-recipients";
      description = ''
        Command to send a mail. If not set, neomutt will be in charge of sending mails.
      '';
    };

    imap.idle = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set, neomutt will attempt to use the IDLE extension.
      '';
    };

    mailboxes = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["github" "Lists/nix" "Lists/haskell-cafe"];
      description = ''
        A list of mailboxes.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = "color status cyan default";
      description = ''
        Extra lines to add to the folder hook for this account.
      '';
    };
  };
}
