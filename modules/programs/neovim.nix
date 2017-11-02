{ config, lib, pkgs, ... }:

with lib;

# la config de vim est dans /etc/vim
let

  cfg = config.programs.vim;
  defaultPlugins = [ "sensible" ];

  knownSettings = {
    background = types.enum [ "dark" "light" ];
    copyindent = types.bool;
    expandtab = types.bool;
    hidden = types.bool;
    history = types.int;
    ignorecase = types.bool;
    modeline = types.bool;
    number = types.bool;
    relativenumber = types.bool;
    shiftwidth = types.int;
    smartcase = types.bool;
    tabstop = types.int;
  };

  vimSettingsType = types.submodule {
    options =
      let
        opt = name: type: mkOption {
          type = types.nullOr type;
          default = null;
          visible = false;
        };
      in
        mapAttrs opt knownSettings;
  };

  setExpr = name: value:
    let
      v =
        if isBool value then (if value then "" else "no") + name
        else name + "=" + toString value;
    in
      optionalString (value != null) ("set " + v);

in

{
  options = {
    programs.neovim = {
      enable = mkEnableOption "Neovim";

      withPython = mkOption {
        type = types.nullOr types.bool;
        default = true;
        description = ''
          Enable python2 provider. Set to true to use python2-based plugins
        '';
      };

      withRuby = mkOption {
        type = types.nullOr types.bool;
        default = true;
        description = ''
          Enable ruby provider
        '';
      };

      withPython3 = mkOption {
        type = types.nullOr types.bool;
        default = true;
        description = ''
          Enable python3 provider. Set to true to use python2-based plugins
        '';
      };

      vimAlias = mkOption {
        type = types.nullOr types.bool;
        default = false;
        description = ''
          Whether to use python3 plugins
        '';
      };

      extraPython3Packages = mkOption {
        type = types.listOf types.package;
        # todo add provider ofc ! 
        default = [];
        example = [  ];
        description = ''
          TODO
          <link xlink:href="https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/vim-plugin-names"/>.
        '';
      };

# , withPython ? true, pythonPackages, extraPythonPackages ? []

      # plugins = mkOption {
      #   type = types.listOf types.str;
      #   default = defaultPlugins;
      #   example = [ "YankRing" ];
      #   description = ''
      #     List of vim plugins to install. For supported plugins see:
      #     <link xlink:href="https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/vim-plugin-names"/>.
      #   '';
      # };

#       settings = mkOption {
#         type = vimSettingsType;
#         default = {};
#         example = literalExample ''
#           {
#             expandtab = true;
#             history = 1000;
#             background = "dark";
#           }
#         '';
#         description = ''
#           At attribute set of Vim settings. The attribute names and
#           corresponding values must be among the following supported
#           options.

#           <informaltable frame="none"><tgroup cols="1"><tbody>
#           ${concatStringsSep "\n" (
#             mapAttrsToList (n: v: ''
#               <row>
#                 <entry><varname>${n}</varname></entry>
#                 <entry>${v.description}</entry>
#               </row>
#             '') knownSettings
#           )}
#           </tbody></tgroup></informaltable>

#           See the Vim documentation for detailed descriptions of these
#           options. Note, use <varname>extraConfig</varname> to
#           manually set any options not listed above.
#         '';
#       };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = ''
        '';
        description = "Custom .vimrc lines";
      };

      package = mkOption {
        type = types.package;
        description = "Resulting customized vim package";
        readOnly = true;
      };
    };
  };

  config = 
    let
      customRC = ''
        ${concatStringsSep "\n" (
          filter (v: v != "") (
          mapAttrsToList setExpr (
          builtins.intersectAttrs knownSettings cfg.settings)))}

        ${cfg.extraConfig}
      '';

      # vim = pkgs.vim_configurable.customize {
      #   name = "vim";
      #   vimrcConfig.customRC = customRC;
      #   vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      #   vimrcConfig.vam.pluginDictionaries = [
      #     { names = defaultPlugins ++ cfg.plugins; }
      #   ];
      # };

    in mkIf cfg.enable {

      # TODO allow to customize
      home.packages = [ pkgs.neovim ];


      # pluginPython3Packages = if configure == null then [] else builtins.concatLists
      # (map ({ python3Dependencies ? [], ...}: python3Dependencies)
      # (vimUtils.requiredPlugins configure));
      python3Env = python3Packages.python.buildEnv.override {
        extraLibs = [ python3Packages.neovim ] ++ cfg.extraPython3Packages;
        ignoreCollisions = true;
      };
      python3Wrapper = ''--cmd \"let g:python3_host_prog='$out/bin/nvim-python3'\" '';
      pythonFlags = optionalString (cfg.withPython || cfg.withPython3) ''--add-flags "${
        (optionalString withPython pythonWrapper) +
        (optionalString withPython3 python3Wrapper)
      }"'';

      # ln -s ${python3Env}/bin/python3 $out/bin/nvim-python3

      # todo register python-language-server binary into path
      # ${cfg.configPath}
      xdg.configFile."nvim/hm.vim".text = ''
        " VIM COMMENT
        '';
    };
  # # '' + optionalString (configure != null) ''
  #   wrapProgram $out/bin/nvim --add-flags "-u ${vimUtils.vimrcFile configure}"
  # '';
}

