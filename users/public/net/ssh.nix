{ username, ... }:
{
  home-manager.users.${username} = {

    home.persistence."/persist" = {
      directories = [ ".ssh" ];
    };

    programs.ssh = {
      enable = true;
      settings = {
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
    };
  };
}
