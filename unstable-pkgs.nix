{ config, lib, ... }:

let
  unstable = import
    (builtins.fetchTarball {
      url = https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
      }
    )
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in

rec {
  environment = {
    systemPackages = with unstable; [
      atuin
      bash-preexec
      tailscale
    ];
    interactiveShellInit = lib.mkIf (builtins.elem unstable.atuin environment.systemPackages) ''
      source ${unstable.bash-preexec}/share/bash/bash-preexec.sh
      # source ${unstable.blesh}/share/blesh/ble.sh
      eval "$(${unstable.atuin}/bin/atuin init bash)"
    '';
  };

  services.tailscale.package = lib.mkIf (lib.elem unstable.tailscale environment.systemPackages) unstable.tailscale;
}
