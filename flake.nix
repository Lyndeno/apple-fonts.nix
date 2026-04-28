{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      flake = false;
    };
    sf-compact = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      flake = false;
    };
    sf-mono = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      flake = false;
    };
    sf-arabic = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
      flake = false;
    };
    sf-armenian = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Armenian.dmg";
      flake = false;
    };
    sf-georgian = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Georgian.dmg";
      flake = false;
    };
    sf-hebrew = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Hebrew.dmg";
      flake = false;
    };
    ny = {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};

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

          makeAppleFont =
            name: pkgName: src: nerd:
            pkgs.stdenvNoCC.mkDerivation {
              inherit name src;

              unpackPhase = unpackPhase pkgName;

              buildInputs =
                [ pkgs.p7zip ]
                ++ pkgs.lib.optionals nerd [
                  pkgs.parallel
                  pkgs.nerd-font-patcher
                ];

              setSourceRoot = "sourceRoot=`pwd`";

              buildPhase = pkgs.lib.optionalString nerd ''
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
                  if nerd then ''
                    find -name \*.otf -maxdepth 1 -exec mv {} "$out/share/fonts/opentype/" \;
                    find -name \*.ttf -maxdepth 1 -exec mv {} "$out/share/fonts/truetype/" \;
                  '' else ''
                    find -name \*.otf -exec mv {} "$out/share/fonts/opentype/" \;
                    find -name \*.ttf -exec mv {} "$out/share/fonts/truetype/" \;
                  ''
                )
                + commonHydraProducts
                + ''runHook postInstall'';
            };

          fontDefs = [
            { name = "sf-pro";      pkgName = "SF Pro Fonts.pkg";      input = inputs.sf-pro; }
            { name = "sf-compact";  pkgName = "SF Compact Fonts.pkg";  input = inputs.sf-compact; }
            { name = "sf-mono";     pkgName = "SF Mono Fonts.pkg";     input = inputs.sf-mono; }
            { name = "sf-arabic";   pkgName = "SF Arabic Fonts.pkg";   input = inputs.sf-arabic; }
            { name = "sf-armenian"; pkgName = "SF Armenian Fonts.pkg"; input = inputs.sf-armenian; }
            { name = "sf-georgian"; pkgName = "SF Georgian Fonts.pkg"; input = inputs.sf-georgian; }
            { name = "sf-hebrew";   pkgName = "SF Hebrew Fonts.pkg";   input = inputs.sf-hebrew; }
            { name = "ny";          pkgName = "NY Fonts.pkg";          input = inputs.ny; }
          ];
        in
        pkgs.lib.foldl' (
          acc: f:
          acc
          // {
            ${f.name} = makeAppleFont f.name f.pkgName f.input false;
            "${f.name}-nerd" = makeAppleFont "${f.name}-nerd" f.pkgName f.input true;
          }
        ) { } fontDefs
      );
      hydraJobs = {
        packages = {
          # hydra does not have Mac runners connected
          inherit (self.packages) x86_64-linux aarch64-linux;
        };
      };
    };
}
