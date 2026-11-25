{
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "gutworm";
          email = "gvtworm@gmail.com";
        };
        init.defaultBranch = "main";
      };
      ignores = [
        ".direnv"
      ];
    };
  };
}
