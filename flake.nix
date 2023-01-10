{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, sf-pro }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      packages.sf-pro = pkgs.stdenv.mkDerivation {
        name = "sf-pro";
        version = "0.0.1";

        src = sf-pro;
        buildInputs = [ pkgs.undmg pkgs.p7zip ];
        setSourceRoot = "sourceRoot=`pwd`";

        dontUnpack = true;

        installPhase = ''
          undmg $src
          7z x 'SF Pro Fonts.pkg'
          7z x 'Payload~'
          mkdir -p $out/share/fonts
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          mv Library/Fonts/*.otf $out/share/fonts/opentype
          mv Library/Fonts/*.ttf $out/share/fonts/truetype
        '';
      };
    }
  );
}
