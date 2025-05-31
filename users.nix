{
  users = {
    mutableUsers = false;
    users.zgr = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$P1mFfsiwDtUFeuVUIRSmt/$enBCo06VCCq804jbnzJRBQnqR1fZgjKmO.ESVoWhAN3";  # printf password | mkpasswd -s
      home = "/home/zgr";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        #"podman"
        #"render"
        #"video"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5ZoG0AtQlWgFJaIYnRznbgxQ/NQEvQunUzHcXgAT/p nixos"  # ssh-keygen -t ed25519 -f </folder/keyfile> -C <comment>
      ];
      # packages = with pkgs; [
      #   tree
      # ];
    };
  };
}