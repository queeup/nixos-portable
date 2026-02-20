{
  fileSystems = {
    "/".options = [ "subvol=@" "compress=zstd" "noatime" "nodiscard" ];
    "/home".options = [ "subvol=@home" "compress=zstd" "noatime" "nodiscard" ];
    "/nix".options = [ "subvol=@nix" "noatime" "nodiscard" ];
    "/swap".options = [ "subvol=@swap" "noatime" "nodiscard" ];
    "/var".options = [ "subvol=@var" "noatime" "nodiscard" ];
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024; # 8GB
    }
  ];
}