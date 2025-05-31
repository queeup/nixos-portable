{
  fileSystems = {
    "/".options = [ "subvol=@" "compress=zstd" "noatime" ];
    "/home".options = [ "subvol=@home" "compress=zstd" "noatime" ];
    # "/nix".options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    "/swap".options = [ "subvol=@swap" ];
    "/var/log".options = [ "subvol=@log" "compress=zstd" "noatime" ];
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024; # 8GB} ];
    }
  ];
}