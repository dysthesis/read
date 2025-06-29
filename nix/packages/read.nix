{
  glow,
  cleanutil,
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
    cleanutil
    glow
  ];
  checkPhase = false;
}
