{ config, lib, ... }:

{
  options.home.shell = {
    enableShellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Whether to globally enable shell integration for all supported shells.

        Individual shell integrations can be overridden with their respective
        `shell.enable<SHELL>Integration` option. For example, the following
        declaration globally disables shell integration for Bash:

        ```nix
        home.shell.enableBashIntegration = false;
        ```
      '';
    };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption {
      inherit config;
      baseName = "Shell";
    };
    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption {
      inherit config;
      baseName = "Shell";
    };
    enableIonIntegration = lib.hm.shell.mkIonIntegrationOption {
      inherit config;
      baseName = "Shell";
    };
    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption {
      inherit config;
      baseName = "Shell";
    };
    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption {
      inherit config;
      baseName = "Shell";
    };

    aliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = lib.literalExpression ''
        {
          g = "git";
          "..." = "cd ../..";
        }
      '';
      description = ''
        An attribute set that maps aliases (the top level attribute names
        in this option) to command strings or directly to build outputs.

        This option should only be used to manage simple aliases that are
        compatible across all shells. If you need to use a shell specific
        feature then make sure to use a shell specific option, for example
        [](#opt-programs.bash.shellAliases) for Bash.
      '';
    };
  };

  config = {
    programs.bash.shellAliases = config.home.shell.aliases;
    programs.zsh.shellAliases = config.home.shell.aliases;
    programs.fish.shellAliases = config.home.shell.aliases;
    programs.nushell.shellAliases = config.home.shell.aliases;
  };
}
