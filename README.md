# San Francisco Fonts

> [!Note]
> The fonts are sourced directly from Apple, via [apple.com](https://apple.com).
> Add this flake as a font package, then configure your programs to use it.

>[!Tip]
> Packages are also provided that automatically patch the fonts with the [nerd font patcher](https://github.com/ryanoasis/nerd-fonts). This provides a font that includes the most common symbols, suitable for use in the terminal, statusbars, etc.

## CONFIGURATION EXAMPLE

```nix
{
  description = "Configuration Demonstration";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # San Francisco Fonts | Apple Fonts
  inputs.apple-fonts.url= "github:Lyndeno/apple-fonts.nix";
  inputs.apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, apple-fonts.nix }: {
    nixosConfigurations = {
      # NOTE: change "host" to your system's hostname
      host = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix

        ];
      };
    };
  };
}
```

## USAGE EXAMPLE
### via [stylix](https://stylix.danth.me/):

```nix
stylix.fonts = {
    serif = {
        package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
    };
};
```

>[!Important]
> Stylix needs to be enabled and imported as well.
Leading to a full example looking more like:

```nix
{
  description = "Configuration Demonstration";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # San Francisco Fonts | Apple Fonts
  inputs.apple-fonts.url= "github:Lyndeno/apple-fonts.nix";
  inputs.apple-fonts.inputs.nixpkgs.follows = "nixpkgs";

  # Stylix
  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, apple-fonts, stylix }: {
    nixosConfigurations = {
      # NOTE: change "host" to your system's hostname
      host = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          stylix.nixosModules.stylix
        ];
      };
    };
  };
}
```
