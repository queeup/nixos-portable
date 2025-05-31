{ pkgs, config, ... }:

let
  unstable = import
    (builtins.fetchTarball {
      url = https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
      }
    )
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in

{
  environment = {
    systemPackages = with pkgs; [
      unstable.hishtory
      unstable.tailscale
    ];
    # Dont use loginShellInit. bind: command not found
    interactiveShellInit = ''
      # hiSHtory: https://github.com/ddworken/hishtory
      if [ ! -d ".hishtory" ]; then
        ${unstable.hishtory}/bin/hishtory init
        ${unstable.hishtory}/bin/hishtory config-set filter-duplicate-commands true
        ${unstable.hishtory}/bin/hishtory config-set displayed-columns Hostname Timestamp Command
        ${unstable.hishtory}/bin/hishtory config-set timestamp-format '2006/01/25 15:04'
      fi
      source ${unstable.hishtory}/share/hishtory/config.sh
      source <(${unstable.hishtory}/bin/hishtory completion bash)
      # source $(nix --extra-experimental-features "nix-command flakes" eval -f '<nixpkgs>' --raw 'hishtory')/share/his>
    '';
  };
  
  services.tailscale.package = unstable.tailscale;
}
