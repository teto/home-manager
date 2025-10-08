{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  extraMailboxOptions = {
    options = {
      mailbox = mkOption {
        type = types.str;
        example = "Sent";
        description = "Name of mailbox folder to be included";
      };

      name = mkOption {
        type = types.nullOr types.str;
        example = "Junk";
        default = null;
        description = "Name to display";
      };

      type = mkOption {
        type = types.nullOr (
          types.enum [
            "maildir"
            "imap"
          ]
        );
        example = "imap";
        default = null;
        description = "Whether this mailbox is a maildir folder or an IMAP mailbox";
      };
    };
  };

in
{
  options.notmuch.neomutt = {
    enable = lib.mkEnableOption "Notmuch support in NeoMutt" // {
      default = true;
    };

    virtualMailboxes = mkOption {
      type = types.listOf (types.submodule ../notmuch/virtual-mailbox.nix);
      example = [
        {
          name = "My INBOX";
          query = "tag:inbox";
        }
      ];
      default = [
        {
          name = "My INBOX";
          query = "tag:inbox";
        }
      ];
      description = "List of virtual mailboxes using Notmuch queries";
    };
  };

  options.neomutt = {
    enable = lib.mkEnableOption "NeoMutt";

    sendMailCommand = mkOption {
      type = types.nullOr types.str;
      default = if config.msmtp.enable then "msmtpq --read-envelope-from --read-recipients" else null;
      defaultText = lib.literalExpression ''
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

    # sendMailCommand = mkOption {
    #   type = types.nullOr types.str;
    #   default = null;
    #   example = "msmtpq --read-envelope-from --read-recipients";
    #   description = ''
    #     Command to send a mail. If not set, mutt will be in charge of sending mails.
    #   '';
    # };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = "color status cyan default";
      description = ''
        Extra lines to add to the folder hook for this account.
      '';
    };

    showDefaultMailbox = mkOption {
      type = types.bool;
      default = true;
      description = "Show the default mailbox (INBOX)";
    };

    mailboxName = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "==== <mailbox-name> ===";
      description = "Use a different name as mailbox name";
    };

    mailboxType = mkOption {
      type = types.enum [
        "maildir"
        "imap"
      ];
      default = "maildir";
      example = "imap";
      description = "Whether this account uses maildir folders or IMAP mailboxes";
    };

    extraMailboxes = mkOption {
      type = with types; listOf (either str (submodule extraMailboxOptions));
      default = [ ];
      description = "List of extra mailboxes";
    };
  };
}
