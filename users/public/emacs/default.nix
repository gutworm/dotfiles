{
  username,
  inputs,
  pkngs,
  ...
}:
{
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];

  home-manager.users.${username} =
    {
      pkgs,
      ...
    }:
    {

      home = {
        persistence."/persist" = {
          directories = [ ".emacs.d" ];
        };
        sessionVariables = {
          ALTERNATE_EDITOR = "";
          EDITOR = "emacsclient -nw"; # $EDITOR opens in terminal
          VISUAL = "emacsclient -c -a emacs"; # $VISUAL opens in GUI mode
        };
        packages = with pkgs; [
	  hunspell
	  hunspellDicts.en_US
	  hunspellDicts.ru_RU
        ];
      };

      programs = {
        info.enable = true;
        emacs = {
          enable = true;
          package = (
            pkgs.emacsWithPackagesFromUsePackage {
              package = pkgs.emacs-unstable-pgtk;
              defaultInitFile = true;
              config = ./init.el;
              extraEmacsPackages = epkgs: [
                (epkgs.treesit-grammars.with-grammars (grammars: [
                  grammars.tree-sitter-nix
                ]))
              ];
            }
          );
        };
      };
    };
}
