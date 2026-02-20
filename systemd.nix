{ pkgs, ...}: {
  systemd.services.flatpak-add-repo = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      ConditionPathExists = "!/var/lib/%N.stamp";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
        "${pkgs.coreutils}/bin/touch /var/lib/%N.stamp"
        #"/run/current-system/sw/bin/touch /var/lib/%N.stamp"
      ];
    };
  };

  systemd.services.flatpak-install-apps = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig = {
      ConditionPathExists = [
        "/var/lib/flatpak-add-repo.stamp"
        "!/var/lib/%N.stamp"
      ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ''${pkgs.flatpak}/bin/flatpak install --system --assumeyes flathub \
            org.gnome.baobab \
            org.gnome.Boxes \
            org.gnome.Calculator \
            org.gnome.Calendar \
            org.gnome.clocks \
            org.gnome.Decibels \
            org.gnome.FileRoller \
            org.gnome.Geary \
            org.gnome.Logs \
            org.gnome.Loupe \
            org.gnome.NautilusPreviewer \
            org.gnome.NetworkDisplays \
            org.gnome.Papers \
            org.gnome.seahorse.Application \
            org.gnome.TextEditor \
            org.gnome.Weather \
            org.bleachbit.BleachBit \
            org.freedesktop.Platform.ffmpeg-full//24.08 \
            org.mozilla.firefox \
            org.onlyoffice.desktopeditors \
            org.telegram.desktop \
            org.upscayl.Upscayl \
            com.bitwarden.desktop \
            com.discordapp.Discord \
            com.github.tchx84.Flatseal \
            com.github.jeromerobert.pdfarranger \
            com.github.qarmin.czkawka \
            com.github.qarmin.szyszka \
            org.localsend.localsend_app \
            com.logseq.Logseq \
            io.github.celluloid_player.Celluloid \
            io.github.nokse22.inspector \
            io.github.nozwock.Packet \
            io.github.shiftey.Desktop \
            im.riot.Riot \
            de.haeckerfelix.Fragments \
            app.fotema.Fotema
        ''
        "${pkgs.coreutils}/bin/touch /var/lib/%N.stamp"
        #"/run/current-system/sw/bin/touch /var/lib/%N.stamp"
      ];
    };
  };
}