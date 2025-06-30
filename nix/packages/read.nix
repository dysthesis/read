{
  mdcat,
  clean,
  uutils-findutils,
  jq,
  fzf,
  sim,
  r,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "read";
  text = builtins.readFile ../../read;
  runtimeInputs = [
    sim
    jq
    fzf
    r
    uutils-findutils
    clean
    mdcat
  ];
  checkPhase = false;
}
