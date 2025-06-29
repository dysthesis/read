{ pkgs, ... }:
pkgs.mkShell {
  name = "read";

  packages = with pkgs; [
    nixd
    alejandra
    statix
    deadnix
    cargo
    bacon
    shellcheck
    shfmt
    bash-language-server
  ];
}
