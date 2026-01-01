{ pkgs, ... }: {

  environment = {
    extraSetup = ''
      # sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/xterm.desktop
      # sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/cups.desktop
      # sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/org.gnome.Extensions.desktop
      # sed -i 's/Exec=.*/Exec=/' $out/share/applications/org.gnome.Extensions.desktop
      # sed -i 's/\[Desktop Entry\]/\[Desktop Entry\]\nNoDisplay=1/' $out/share/applications/org.gnome.Shell.Extensions.desktop
      sed -i -E 's|^(Name([[a-zA-Z_]+])?)=Ptyxis$|\1=Terminal|' $out/share/applications/org.gnome.Ptyxis.desktop
      # rm $out/share/applications/cups.desktop
    '';
    gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];
    systemPackages = with pkgs; [
      nautilus
      ptyxis
    ];
    interactiveShellInit = ''
      export LC_MESSAGES=C.UTF-8  # for terminal messages
    '';
  };

  i18n = {
    defaultLocale = "tr_TR.UTF-8";
  };

  services = {
    flatpak.enable = true;
    libinput.enable = true;
    # printing.enable = true;
    gnome.core-apps.enable = false;
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "user";
      gdm.enable = true;
    };
    desktopManager.gnome.enable = true;
  };
}