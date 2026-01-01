{
  fileSystems = {
    "/".options = [ "subvol=@" "compress=zstd" "noatime" ];
    "/home".options = [ "subvol=@home" "compress=zstd" "noatime" ];
    "/nix".options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    "/swap".options = [ "subvol=@swap" ];
    "/var".options = [ "subvol=@var" "noatime" ];
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 4 * 1024; # 4GB
    }
  ];
}