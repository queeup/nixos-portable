{
  fileSystems = {
    "/".options = [ "subvol=@" "compress=zstd" "noatime" ];
    "/home".options = [ "subvol=@/home" "compress=zstd" "noatime" ];
    "/swap".options = [ "subvol=@/swap" ];
    "/var/lib/flatpak".options = [ "subvol=@/var/lib/flatpak" "compress=zstd" "noatime" ];
    "/var/log".options = [ "subvol=@/var/log" "compress=zstd" "noatime" ];
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024; # 8GB} ];
    }
  ];
}