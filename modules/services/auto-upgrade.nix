{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.autoUpgrade; in

{

  options = {

    services.autoUpgrade = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to periodically upgrade NixOS to the latest
          version. If enabled, a systemd timer will run
          <literal>nixos-rebuild switch --upgrade</literal> once a
          day.
        '';
      };

      # channel = mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   example = "https://nixos.org/channels/nixos-14.12-small";
      #   description = ''
      #     The URI of the NixOS channel to use for automatic
      #     upgrades. By default, this is the channel set using
      #     <command>nix-channel</command> (run <literal>nix-channel
      #     --list</literal> to see the current value).
      #   '';
      # };

      flags = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "-I" "stuff=/home/alice/nixos-stuff" "--option" "extra-binary-caches" "http://my-cache.example.org/" ];
        description = ''
          Any additional flags passed to <command>nixos-rebuild</command>.
        '';
      };

      # dates = mkOption {
      #   default = "04:40";
      #   type = types.str;
      #   description = ''
      #     Specification (in the format described by
      #     <citerefentry><refentrytitle>systemd.time</refentrytitle>
      #     <manvolnum>7</manvolnum></citerefentry>) of the time at
      #     which the update will occur.
      #   '';
      # };

      frequency = mkOption {
        type = types.str;
        default = "*:0/5";
        description = ''
          How often to update home-manager
        '';
      };


      # randomizedDelaySec = mkOption {
      #   default = "0";
      #   type = types.str;
      #   example = "45min";
      #   description = ''
      #     Add a randomized delay before each automatic upgrade.
      #     The delay will be chozen between zero and this value.
      #     This value must be a time span in the format specified by
      #     <citerefentry><refentrytitle>systemd.time</refentrytitle>
      #     <manvolnum>7</manvolnum></citerefentry>
      #   '';
      # };

    };

  };

  config = lib.mkIf cfg.enable {

    services.autoUpgrade.flags =
      # "--no-build-output"
      [  ]
      # ++ (if cfg.channel == null
      #     then [ "--upgrade" ]
      #     else [ "-I" "nixpkgs=${cfg.channel}/nixexprs.tar.xz" ]);
      ;


    systemd.user.services.home-manager-update = {

      Service = {
        Description = "Home-manager update";

        X-StopOnRemoval = false;

        Type = "oneshot";

        # environment = 
        #   { inherit (config.environment.sessionVariables) NIX_PATH;
        #     # HOME = "/root";
        #   } // config.networking.proxy.envVars;

        # path = with pkgs; [ coreutils gnutar xz.bin gzip gitMinimal ];

        ExecStart = let
            # -I nixpkgs=/home/teto/nixpkgs -I nixos-config=/home/teto/home/nixpkgs/configuration-xps.nix
            home-manager = "${config.home.path}/bin/home-manager";
          in ''
              ${home-manager} switch ${toString cfg.flags}
          '';

        # ExecStart = "${pkgs.gmailieer}/bin/gmi sync";
        # WorkingDirectory = account.maildir.absPath;
        # startAt = cfg.dates;
      };
    };

    # systemd.timers.nixos-upgrade.timerConfig.RandomizedDelaySec = cfg.randomizedDelaySec;
    systemd.user.timers.autoUpgrade = {
      Unit = { Description = "Home-manager periodic update"; };
      Timer = {
        Unit = "home-manager-update.service";
        OnCalendar = cfg.frequency;
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

  };

}

