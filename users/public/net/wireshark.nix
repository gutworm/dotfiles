{
  username,
  pkgs,
  ...
}:
{
  users.users.${username}.extraGroups = [ "wireshark" ];
  programs.wireshark = {
    package = pkgs.wireshark;
    enable = true;
    dumpcap.enable = true;
  };
}
