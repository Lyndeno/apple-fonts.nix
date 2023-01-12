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
    sf-mono = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      flake = false;
    };
    sf-arabic = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
      flake = false;
    };
    ny = {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, sf-pro, sf-compact, sf-mono, sf-arabic, ny }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      makeAppleFont = (name: pkgName: src: pkgs.stdenv.mkDerivation {
        inherit name src;

        buildInputs = [ pkgs.undmg pkgs.p7zip ];
        setSourceRoot = "sourceRoot=`pwd`";

        unpackPhase = ''
          undmg $src
          7z x '${pkgName}'
          7z x 'Payload~'
        '';

        installPhase = ''
          mkdir -p $out/share/fonts
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
          find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
        '';
      });
      makeNerdAppleFont = (name: pkgName: src: pkgs.stdenv.mkDerivation {
        inherit name src;

        buildInputs = [ pkgs.undmg pkgs.p7zip pkgs.parallel pkgs.nerd-font-patcher ];
        setSourceRoot = "sourceRoot=`pwd`";

        unpackPhase  = ''
          undmg $src
          7z x '${pkgName}'
          7z x 'Payload~'
        '';

        buildPhase = ''
          find -name \*.ttf -o -name \*.otf -print0 | parallel -j $NIX_BUILD_CORES -0 nerd-font-patcher -c {}
        '';

        installPhase = ''
          mkdir -p $out/share/fonts
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          find -name \*.otf -maxdepth 1 -exec mv {} $out/share/fonts/opentype/ \;
          find -name \*.ttf -maxdepth 1 -exec mv {} $out/share/fonts/truetype/ \;
        '';
      });
    in rec {
      packages = {
        sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" sf-pro;
        sf-pro-nerd = makeNerdAppleFont "sf-pro-nerd" "SF Pro Fonts.pkg" sf-pro;

        sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" sf-compact;
        sf-compact-nerd = makeNerdAppleFont "sf-compact-nerd" "SF Compact Fonts.pkg" sf-compact;

        sf-mono = makeAppleFont "sf-mono" "SF Mono Fonts.pkg" sf-mono;
        sf-mono-nerd = makeNerdAppleFont "sf-mono-nerd" "SF Mono Fonts.pkg" sf-mono;

        sf-arabic = makeAppleFont "sf-arabic" "SF Arabic Fonts.pkg" sf-arabic;
        sf-arabic-nerd = makeNerdAppleFont "sf-arabic-nerd" "SF Arabic Fonts.pkg" sf-arabic;

        ny = makeAppleFont "ny" "NY Fonts.pkg" ny;
        ny-nerd = makeNerdAppleFont "ny-nerd" "NY Fonts.pkg" ny;
      };
    }
  );
}
