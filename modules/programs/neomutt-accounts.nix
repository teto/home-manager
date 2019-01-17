{ config, lib, ... }:

with lib;

{
  options.neomutt = {
    enable = mkEnableOption "NeoMutt";

    # TODO we need some logic on how to 
    externalMta = mkOption {
      type = types.bool;
      default = true;
      description = "Use external smtp";
    };

<<<<<<< HEAD
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
||||||| parent of d7879f6a... now works with gmail
    sendMailCommand = mkOption {
      type = types.nullOr types.str;
      description = ''
        Command to send a mail. If msmtp is enabled for the account,
        then this is set to
        <command>msmtpq --read-envelope-from --read-recipients</command>.
      '';
    };
=======
    # externalMta = mkOption {
    #   type = types.bool;
    #   default = true;
    #   description = "Use external MTA.";
    # };
>>>>>>> d7879f6a... now works with gmail

    # externalMra = mkOption {
    #   type = types.bool;
    #   default = true;
    #   description = "Use external MRA.";
    # };
    # internalImapModule = types.submodule {
    #   options = {
    #     idle = mkOption {
    #       type = types.bool;
    #       default = false;
    #       description = ''
    #         If set, neomutt will attempt to use the IDLE extension.
    #       '';
    #     };
    #     host = mkOption {
    #       type = types.str;
    #       example = "imap.example.org";
    #       description = ''
    #         Hostname of IMAP server.
    #       '';
    #     };

    #     port = mkOption {
    #       type = types.nullOr types.ints.positive;
    #       default = null;
    #       example = 993;
    #       description = ''
    #         The port on which the IMAP server listens. If
    #         <literal>null</literal> then the default port is used.
    #       '';
    #     };

    #     tls = mkOption {
    #       type = tlsModule;
    #       default = {};
    #       description = ''
    #         Configuration for secure connections.
    #       '';
    #     };
    #   };
    # };

    # set query_command="notmuch-addrlookup --mutt '%s'"
    queryCommand = mkOption {
      type = types.nullOr types.str;
      # ${pkgs.notmuch-addrlookup}/bin/
      default = "notmuch-addrlookup --mutt '%s'";
      example = "notmuch-addrlookup --mutt '%s'";
      description = ''
        Command to send a mail. If not set, mutt will be in charge of sending mails.
      '';
    };

    sendMailCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "msmtpq --read-envelope-from --read-recipients";
      description = ''
        Command to send a mail. If not set, mutt will be in charge of sending mails.
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
