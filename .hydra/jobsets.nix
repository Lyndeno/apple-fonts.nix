{
  nixpkgs,
  pulls,
  ...
}: let
  pkgs = import nixpkgs {};

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =
    pkgs.lib.mapAttrs (num: info: {
      enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      checkinterval = 60;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      type = 1;
      flake = "github:Lyndeno/apple-fonts.nix/pull/${num}/head";
    })
    prs;
  mkFlakeJobset = branch: schedulingshares: {
    inherit schedulingshares;
    description = "Build ${branch}";
    checkinterval = "300";
    enabled = "1";
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
    hidden = false;
    type = 1;
    flake = "github:Lyndeno/apple-fonts.nix/${branch}";
  };

  desc =
    prJobsets
    // {
      "master" = mkFlakeJobset "master" 100;
    };

  log = {
    pulls = prs;
    jobsets = desc;
  };
in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
    # This is to get nice .jobsets build logs on Hydra
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}
