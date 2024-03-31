{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mujmap;

  mujmapAccounts =
    filter (a: a.mujmap.enable) (attrValues config.accounts.email.accounts);

  missingNotmuchAccounts = map (a: a.name)
    (filter (a: !a.notmuch.enable && a.mujmap.notmuchSetupWarning)
      mujmapAccounts);

  notmuchConfigHelp =
    map (name: "accounts.email.accounts.${name}.notmuch.enable = true;")
    missingNotmuchAccounts;

  settingsFormat = pkgs.formats.toml { };

  filterNull = attrs: attrsets.filterAttrs (n: v: v != null) attrs;

  # name = "${account.maildir.absPath}/mujmap.toml";
  # value.source = settingsFormat.generate "mujmap-${lib.replaceStrings ["@"] ["-"] account.address}.toml" ({
  configFile = account:
    let
      settings'' = if (account.jmap == null) then
        { }
      else
        filterNull {
          # fqdn = account.jmap.host;
          session_url = account.jmap.sessionUrl;
        };

      settings' = settings'' // {
        username = account.userName;
        password_command = escapeShellArgs account.passwordCommand;
      } // filterNull account.mujmap.settings;

      settings = if (hasAttr "fqdn" settings') then
        (removeAttrs settings' [ "session_url" ])
      else
        settings';
    in {
      name = "${account.maildir.absPath}/mujmap.toml";
      value.source = settingsFormat.generate
        "mujmap-${lib.replaceStrings [ "@" ] [ "_at_" ] account.address}.toml"
        settings;
    };



  # TODO rework that in a mujmap-account.nix

    # accounts.email.accounts = mkOption {
    #   type = with types; attrsOf (submodule (import ./mbsync-accounts.nix));
    # };
  # mujmapModule = types.submodule { options = { mujmap = mujmapOpts; }; };
  mujmapModule = types.submodule ( import ./mujmap-accounts.nix { inherit settingsFormat; } );
in {
  meta.maintainers = with maintainers; [ elizagamedev ];

  options = {
    programs.mujmap = {
      enable = mkEnableOption "mujmap Gmail synchronization for notmuch";

      package = mkOption {
        type = types.package;
        default = pkgs.mujmap;
        defaultText = "pkgs.mujmap";
        description = ''
          mujmap package to use.
        '';
      };
    };

    accounts.email.accounts =
      mkOption { type = with types; attrsOf mujmapModule; };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (missingNotmuchAccounts != [ ]) {
      warnings = [''
        mujmap is enabled for the following email accounts, but notmuch is not:

            ${concatStringsSep "\n    " missingNotmuchAccounts}

        Notmuch can be enabled with:

            ${concatStringsSep "\n    " notmuchConfigHelp}

        If you have configured notmuch outside of Home Manager, you can suppress this
        warning with:

            programs.mujmap.notmuchSetupWarning = false;
      ''];
    })

    {
      warnings = flatten (map (account: account.warnings) mujmapAccounts);

      home.packages = [ cfg.package ];

      # Notmuch should ignore non-mail files created by mujmap.
      programs.notmuch.new.ignore = [ "/.*[.](toml|json|lock)$/" ];

      # temporarily disabled
      # home.file = listToAttrs (map configFile mujmapAccounts);
    }
  ]);
}
