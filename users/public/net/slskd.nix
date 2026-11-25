{
  lib,
  config,
  username,
  ...
}:
let
  homeDir = config.home-manager.users.${username}.home.homeDirectory;
in
{
  home-manager.users.${username} = {
    home.persistence."/persist" = {
      directories = [
        ".local/share/slskd"
      ];
    };
  };

  services.slskd = {
    enable = true;
    environmentFile = config.sops.templates."slskd_env".path;
    settings = {
      shares.directories = [
        "[Albums]${homeDir}/Music/Albums"
      ];
    };
  };

  systemd.services.slskd.wantedBy = lib.mkForce [ ];
}
