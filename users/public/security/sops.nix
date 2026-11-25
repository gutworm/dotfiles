{
  inputs,
  config,
  username,
  ...
}:
let
  key_location = "/persist/var/lib/sops-nix/key.txt";
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;

    secrets = {
      "${username}_password" = {
        neededForUsers = true;
        key = "${username}_password";
        group = "users";
        mode = "0440";
      };
      soulseek_username = { };
      soulseek_password = { };
      slskd_password = { };
    };
    templates = {
      "slskd_env".content = ''
        SLSKD_SLSK_USERNAME=${config.sops.placeholder.soulseek_username}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder.soulseek_password}
        SLSKD_USERNAME=${config.sops.placeholder.soulseek_username}
        SLSKD_PASSWORD=${config.sops.placeholder.slskd_password}
      '';
    };

    age = {
      # key must be in persisted directory
      keyFile = key_location;
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];
  };

  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = key_location;
  };

  users.users.${username} = {
    hashedPasswordFile = config.sops.secrets."${username}_password".path;
  };
}
