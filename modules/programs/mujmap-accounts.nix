{ settingsFormat}:
{ config, pkgs, lib, ... }:
with lib;
let
  # settingsFormat = pkgs.formats.toml { };
  tagsOpts = {
    lowercase = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, translate all mailboxes to lowercase names when mapping to notmuch
        tags.
      '';
    };

    directory_separator = mkOption {
      type = types.str;
      default = "/";
      example = ".";
      description = ''
        Directory separator for mapping notmuch tags to maildirs.
      '';
    };

    inbox = mkOption {
      type = types.str;
      default = "inbox";
      description = ''
        Tag for notmuch to use for messages stored in the mailbox labeled with the
        `Inbox` name attribute.

        If set to an empty string, this mailbox *and its child
        mailboxes* are not synchronized with a tag.
      '';
    };

    deleted = mkOption {
      type = types.str;
      default = "deleted";
      description = ''
        Tag for notmuch to use for messages stored in the mailbox labeled with the
        `Trash` name attribute.

        If set to an empty string, this mailbox *and its child
        mailboxes* are not synchronized with a tag.
      '';
    };

    sent = mkOption {
      type = types.str;
      default = "sent";
      description = ''
        Tag for notmuch to use for messages stored in the mailbox labeled with the
        `Sent` name attribute.

        If set to an empty string, this mailbox *and its child
        mailboxes* are not synchronized with a tag.
      '';
    };

    spam = mkOption {
      type = types.str;
      default = "spam";
      description = ''
        Tag for notmuch to use for messages stored in the mailbox labeled with the
        `Junk` name attribute and/or with the `$Junk` keyword,
        *except* for messages with the `$NotJunk` keyword.

        If set to an empty string, this mailbox, *its child
        mailboxes*, and these keywords are not synchronized with a tag.
      '';
    };

    important = mkOption {
      type = types.str;
      default = "important";
      description = ''
        Tag for notmuch to use for messages stored in the mailbox labeled with the
        `Important` name attribute and/or with the `$Important`
        keyword.

        If set to an empty string, this mailbox, *its child
        mailboxes*, and these keywords are not synchronized with a tag.
      '';
    };

    phishing = mkOption {
      type = types.str;
      default = "phishing";
      description = ''
        Tag for notmuch to use for the IANA `$Phishing` keyword.

        If set to an empty string, this keyword is not synchronized with a tag.
      '';
    };
  };

  rootOpts = {
    username = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "alice@example.com";
      description = ''
        Username for basic HTTP authentication.

        If `null`, defaults to
        [](#opt-accounts.email.accounts._name_.userName).
      '';
    };

    password_command = mkOption {
      type = types.nullOr (types.either types.str (types.listOf types.str));
      default = null;
      apply = p: if isList p then escapeShellArgs p else p;
      example = "pass alice@example.com";
      description = ''
        Shell command which will print a password to stdout for basic HTTP
        authentication.

        If `null`, defaults to
        [](#opt-accounts.email.accounts._name_.passwordCommand).
      '';
    };

    fqdn = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "example.com";
      description = ''
        Fully qualified domain name of the JMAP service.

        mujmap looks up the JMAP SRV record for this host to determine the JMAP session
        URL. Mutually exclusive with
        [](#opt-accounts.email.accounts._name_.mujmap.settings.session_url).

        If `null`, defaults to
        [](#opt-accounts.email.accounts._name_.jmap.host).
      '';
    };

    session_url = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://jmap.example.com/.well-known/jmap";
      description = ''
        Session URL to connect to.

        Mutually exclusive with
        [](#opt-accounts.email.accounts._name_.mujmap.settings.fqdn).

        If `null`, defaults to
        [](#opt-accounts.email.accounts._name_.jmap.sessionUrl).
      '';
    };

    auto_create_new_mailboxes = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to create new mailboxes automatically on the server from notmuch
        tags.
      '';
    };

    cache_dir = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The cache directory in which to store mail files while they are being
        downloaded. The default is operating-system specific.
      '';
    };

    tags = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = tagsOpts;
      };
      default = { };
      description = ''
        Tag configuration.

        Beware that there are quirks that require manual consideration if changing the
        values of these files; please see
        <https://github.com/elizagamedev/mujmap/blob/main/mujmap.toml.example>
        for more details.
      '';
    };
  };
in


  {
    options.mujmap = with lib; {
    enable = mkEnableOption "mujmap JMAP synchronization for notmuch";

    sync = mkEnableOption "Sync";

    notmuchSetupWarning = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Warn if Notmuch is not also enabled for this account.

        This can safely be disabled if {file}`mujmap.toml` is managed
        outside of Home Manager.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = rootOpts;
      };
      default = { };
      description = ''
        Settings which are applied to {file}`mujmap.toml`
        for the account.

        See the [mujmap project](https://github.com/elizagamedev/mujmap)
        for documentation of settings not explicitly covered by this module.
      '';
    };
  };
}