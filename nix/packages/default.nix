{
  self,
  pkgs,
  lib,
  inputs,
  ...
}: rec {
  default = read;
  read = pkgs.callPackage ./read.nix {
    inherit pkgs inputs lib self;
    inherit (inputs.sim.packages.${pkgs.system}) sim;
    inherit (inputs.r.packages.${pkgs.system}) r;
    cleanutil = inputs.clean.packages.${pkgs.system}.clean;
  };
}
