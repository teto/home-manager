{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.muchsync;

  # mkIniKeyValue = key: value:
  #   let
  #     tweakVal = v:
  #       if isString v then v
  #       else if isList v then concatMapStringsSep ";" tweakVal v
  #       else if isBool v then (if v then "true" else "false")
  #       else toString v;
  #   in
  #     "${key}=${tweakVal value}";

in {

  # Since muchsync replicates the tags in the notmuch database itself, you should consider disabling maildir flag synchronization by executing:
  # notmuch config set maildir.synchronize_flags=false
}

