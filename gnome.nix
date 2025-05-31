{ config, pkgs, ... }: {

  environment = {
    extraSetup = ''
      # sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/xterm.desktop
      sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/cups.desktop
      sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/org.gnome.Extensions.desktop
      sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/org.gnome.Shell.Extensions.desktop
      sed -i -E 's|^(Name([[a-zA-Z_]+])?)=Ptyxis$|\1=Terminal|' $out/share/applications/org.gnome.Ptyxis.desktop
      # rm $out/share/applications/cups.desktop
    '';

    gnome.excludePackages = with pkgs; [
      decibels
      epiphany
      evince
      gnome-characters
      gnome-console
      gnome-connections
      gnome-contacts
      gnome-font-viewer
      gnome-maps
      gnome-music
      gnome-shell-extensions
      gnome-software
      gnome-tour
      simple-scan
      snapshot
      totem
      yelp
    ];
    systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
      ptyxis
      papers
    ];
  };

  i18n = {
    defaultLocale = "tr_TR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "tr_TR.UTF-8";
      LC_IDENTIFICATION = "tr_TR.UTF-8";
      LC_MEASUREMENT = "tr_TR.UTF-8";
      LC_MONETARY = "tr_TR.UTF-8";
      LC_NAME = "tr_TR.UTF-8";
      LC_NUMERIC = "tr_TR.UTF-8";
      LC_PAPER = "tr_TR.UTF-8";
      LC_TELEPHONE = "tr_TR.UTF-8";
      LC_TIME = "tr_TR.UTF-8";
    };
  };

  services = {
    flatpak.enable = true;
    libinput.enable = true;
    printing.enable = true;
    # gnome.core-apps.enable = false;
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "zgr";
    };
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
      };
      desktopManager.gnome.enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb.layout = "tr";
    };
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd = {
    services."getty@tty1".enable = false;
    services."autovt@tty1".enable = false;
  };
}