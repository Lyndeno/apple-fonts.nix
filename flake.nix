{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    ci.url = "github:Lyndeno/ci";
    ci.inputs.nixpkgs.follows = "nixpkgs";
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
    inputs@{ self, ci, ... }:
    let
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      hydraSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
      forEachHydraSystem = inputs.nixpkgs.lib.genAttrs hydraSystems;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};

          #makeAppleFont =
          #  name: pkgName: src: nerd:
          #  ;

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
            ${f.name} = pkgs.callPackage ./fontPackage.nix { inherit (f) name pkgName; src = f.input; nerd = false; };
            "${f.name}-nerd" = pkgs.callPackage ./fontPackage.nix { inherit (f) pkgName; name = "${f.name}-nerd"; src = f.input; nerd = true; };
          }
        ) { } fontDefs
        // {
          hydra-spec = ci.lib.mkHydraSpec {
            inherit pkgs;
            owner = "Lyndeno";
            repo = "apple-fonts.nix";
          };
          mergify = ci.lib.mkMergifyConfig {
            inherit pkgs;
            projectName = "apple-fonts";
            checks = self.checks;
          };
        }
      );
      checks = forEachHydraSystem (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        # All packages become checks so Hydra builds every font.
        # The ci-specific entries override the package versions with
        # proper check derivations.
        self.packages.${system}
        // {
          hydra-spec = ci.lib.mkHydraCheck {
            inherit pkgs;
            specPackage = self.packages.${system}.hydra-spec;
            specFile = ./.hydra/spec.json;
          };
          mergify-check = ci.lib.mkMergifyCheck {
            inherit pkgs;
            mergifyPackage = self.packages.${system}.mergify;
            mergifyFile = ./.mergify.yml;
          };
        }
      );
    };
}
