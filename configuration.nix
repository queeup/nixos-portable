{ config, pkgs, ... }: {
  imports = [
    # "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/common/gpu/intel"
    ./hardware-configuration.nix
    ./filesystems.nix
    ./gnome.nix
    ./systemd.nix
    ./users.nix
    ./unstable-pkgs.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;  # https://nixos.wiki/wiki/Linux_kernel
    kernelParams = [
      "mitigations=off"
      "i915.enable_fbc=1"
      "i915.enable_guc=2"  # for intel-media-driver
      # "i915.guc_firmware_path=${pkgs.linux-firmware}/lib/firmware/i915/"
      "pcie_aspm=off"  # https://bbs.archlinux.org/viewtopic.php?pid=1183372#p1183372
                       # https://serverfault.com/questions/226319/what-does-pcie-aspm-do
                       # https://serverfault.com/a/219658
      # "usbcore.autosuspend=-1"  # for usb enclosure
      "net.ifnames=0"
    ];
    # blacklistedKernelModules = [ "iTCO_wdt" ];  # https://wiki.archlinux.org/title/Improving_performance#Watchdogs
    # extraModprobeConfig = "options i915 enable_guc=2";
    # kernel.sysctl = { "vm.swappiness" = 10 };
    initrd.kernelModules = [ "i915" ];
    readOnlyNixStore = true;
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    loader = {
      timeout = 2;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  console = {
    keyMap = "trq";
  };

  documentation.enable = false;

  environment = {
    localBinInPath = true;
    etc = {
      "systemd/journald.conf.d/99-storage.conf".text = ''
        [Journal]
        Storage=volatile
        RuntimeMaxUse=100M
        RuntimeKeepFree=20M
      '';
    };
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat --style=plain --pager=never";
      ls = "${pkgs.eza}/bin/eza --group-directories-first";
      ll = "${pkgs.eza}/bin/eza --all --long --group-directories-first --octal-permissions";
      cp = "${pkgs.xcp}/bin/xcp";
      top = "${pkgs.bottom}/bin/btm";
      nano = "${pkgs.nano}/bin/nano -E -w -i";
      nn = "${pkgs.nano}/bin/nano -E -w -i";
      # sudo = "doas";
    };
    systemPackages = with pkgs; [
      # hishtory  # enabled on unstable-pkgs.nix
      duf
    ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver  # iHD
        intel-compute-runtime  # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      ];
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "nixos-portable";
    firewall.enable = false;
    # firewall = {
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    # };
  };

  nix = {
    settings.auto-optimise-store = true;
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  programs.starship.enable = true;

  security = {
    sudo.wheelNeedsPassword = false;
    # sudo.enable = false;
    # doas.enable = true;
    # doas.wheelNeedsPassword = false;
    rtkit.enable = true;  # PulseAudio and PipeWire use this to acquire realtime priority.
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
    fstrim.enable = true;
    # fwupd.enable = true;
    # sshd.enable = true;
    # openssh = {
    #   settings.PasswordAuthentication = false;
    #   settings.PermitRootLogin = "no";
    # };
    tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" "--advertise-routes=192.168.1.0/24" ];
    };
    # hints from https://dataswamp.org/~solene/2021-12-21-my-nixos.html
    cron.systemCronJobs = [
      "0 20 * * * root journalctl --vacuum-time=2d"  # clean logs older than 2d
      # "0 1 * * * root rtcwake -m mem --date +6h"  # auto standby
    ];

    # journald.extraConfig = ''
    #   RateLimitIntervalSec=30s
    #   RateLimitBurst=10000
    # '';
  };

  system = {
    # autoUpgrade.enable = true;
    # autoUpgrade.allowReboot = false;
    # autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
    # stateVersion = "unstable";
    # autoUpgrade.channel = "https://nixos.org/channels/nixos-25.05";
    stateVersion = "25.05";
  };

  time.timeZone = "Europe/Istanbul";

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      liveRestore = false;  # https://github.com/NixOS/nixpkgs/issues/182916
    };
    # podman = {
    #   enable = true;
    #   dockerSocket.enable = true;
    # };
  };
}