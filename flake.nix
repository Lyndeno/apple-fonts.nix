{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      flake = false;
    };
    sf-compact = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, sf-pro, sf-compact }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      makeAppleFont = (name: pkgName: src: pkgs.stdenv.mkDerivation {
        inherit name src;

        buildInputs = [ pkgs.undmg pkgs.p7zip ];
        setSourceRoot = "sourceRoot=`pwd`";

        dontUnpack = true;

        installPhase = ''
          undmg $src
          7z x '${pkgName}'
          7z x 'Payload~'
          mkdir -p $out/share/fonts
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          mv Library/Fonts/*.otf $out/share/fonts/opentype
          mv Library/Fonts/*.ttf $out/share/fonts/truetype
        '';
      });
    in rec {
      packages = {
        sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" sf-pro;
        sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" sf-compact;
      };
    }
  );
}
