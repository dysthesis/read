{
  xq,
  fzf,
  sim,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "read";
  text = builtins.readFile ../../read;
  runtimeInputs = [
    sim
    xq
    fzf
  ];
}
