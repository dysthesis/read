{
  pkgs,
  self,
  ...
}:
pkgs.mkShell {
  name = "read";
  
  packages = with pkgs; [
    nixd
    alejandra
    statix
    deadnix
    cargo
    bacon
  ];
}
