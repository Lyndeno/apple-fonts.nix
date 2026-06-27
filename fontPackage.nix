{
  name,
  pkgName,
  src,
  nerd,
  stdenvNoCC,
  p7zip,
  lib,
  parallel,
  nerd-font-patcher,
}: let
  unpackPhase = pkgName: ''
    runHook preUnpack
    7z x $src
    7z x './*/${pkgName}'
    7z x 'Payload~'
    runHook postUnpack
  '';

  commonInstall = ''
    mkdir -p "$out/share/fonts/opentype"
    mkdir -p "$out/share/fonts/truetype"
  '';

  commonHydraProducts = ''
    mkdir -p "$out/nix-support"
    for f in "$out/share/fonts/opentype/"* "$out/share/fonts/truetype/"*; do
      [ -f "$f" ] && echo "file font $f" >> "$out/nix-support/hydra-build-products"
    done
  '';
in
  stdenvNoCC.mkDerivation {
    inherit name src;

    unpackPhase = unpackPhase pkgName;

    buildInputs =
      [p7zip]
      ++ lib.optionals nerd [
        parallel
        nerd-font-patcher
      ];

    setSourceRoot = "sourceRoot=`pwd`";

    buildPhase = lib.optionalString nerd ''
      runHook preBuild
      find \( -name \*.ttf -o -name \*.otf \) -print0 | parallel --will-cite -j $NIX_BUILD_CORES -0 nerd-font-patcher --no-progressbars -c {}
      runHook postBuild
    '';

    installPhase =
      ''
        runHook preInstall
      ''
      + commonInstall
      + (
        if nerd
        then ''
          find -name \*.otf -maxdepth 1 -exec mv {} "$out/share/fonts/opentype/" \;
          find -name \*.ttf -maxdepth 1 -exec mv {} "$out/share/fonts/truetype/" \;
        ''
        else ''
          find -name \*.otf -exec mv {} "$out/share/fonts/opentype/" \;
          find -name \*.ttf -exec mv {} "$out/share/fonts/truetype/" \;
        ''
      )
      + commonHydraProducts
      + ''runHook postInstall'';
  }
