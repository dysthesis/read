{
  description = "RSS reader";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    r = {
      url = "github:dysthesis/r";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sim = {
      url = "github:dysthesis/sim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clean = {
      url = "github:dysthesis/clean";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal library
    babel = {
      url = "github:dysthesis/babel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    babel,
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    inherit (builtins) mapAttrs;
    inherit (babel) mkLib;
    lib = mkLib nixpkgs;

    # Systems to support
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = lib.babel.forAllSystems {inherit systems;};

    treefmt = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/formatters);
  in
    # Budget flake-parts
    mapAttrs (_: forAllSystems) {
      devShells = pkgs: {default = import ./nix/shell {inherit pkgs self;};};
      # for `nix fmt`
      formatter = pkgs: treefmt.${pkgs.system}.config.build.wrapper;
      # for `nix flake check`
      checks = pkgs: {
        formatting = treefmt.${pkgs.system}.config.build.check self;
      };
      packages = pkgs: import ./nix/packages {inherit self pkgs inputs lib;};
    };
}
