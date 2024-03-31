{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.mujmap;

  mujmapAccounts = filter (a: a.mujmap.enable && a.mujmap.sync)
    (attrValues config.accounts.email.accounts);

  mujmapOptions =
       optional (cfg.verbose) "--verbose"
    ++ optional (cfg.configFile != null) "--config ${cfg.configFile}"
    ++ [ (concatMapStringsSep " -a" (a: a.name) mujmapAccounts) ];
in {
  meta.maintainers = [ maintainers.pjones ];

  options.services.mujmap = {
    enable = mkEnableOption "mujmap";

    package = mkOption {
      type = types.package;
      default = pkgs.mujmap;
      defaultText = literalExpression "pkgs.isync";
      example = literalExpression "pkgs.isync";
      description = "The package to use for the mujmap binary.";
    };

    frequency = mkOption {
      type = types.str;
      default = "*:0/5";
      description = ''
        How often to run mujmap.  This value is passed to the systemd
        timer configuration as the onCalendar option.  See
        {manpage}`systemd.time(7)`
        for more information about the format.
      '';
    };

    verbose = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether mujmap should produce verbose output.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Optional configuration file to link to use instead of
        the default file ({file}`~/.mujmaprc`).
      '';
    };

    preExec = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "mkdir -p %h/mail";
      description = ''
        An optional command to run before mujmap executes.  This is
        useful for creating the directories mujmap is going to use.
      '';
    };

    postExec = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "\${pkgs.mu}/bin/mu index";
      description = ''
        An optional command to run after mujmap executes successfully.
        This is useful for running mailbox indexing tools.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.mujmap" pkgs
        lib.platforms.linux)
    ];

    systemd.user.services.mujmap = {
      Unit = { Description = "mujmap mailbox synchronization"; };

      Service = {
        Type = "oneshot";
        ExecStart =
          "${cfg.package}/bin/mujmap sync ${concatStringsSep " " mujmapOptions}";
      } // (optionalAttrs (cfg.postExec != null) {
        ExecStartPost = cfg.postExec;
      }) // (optionalAttrs (cfg.preExec != null) {
        ExecStartPre = cfg.preExec;
      });
    };

    systemd.user.timers.mujmap = {
      Unit = { Description = "mujmap mailbox synchronization"; };

      Timer = {
        OnCalendar = cfg.frequency;
        Unit = "mujmap.service";
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
