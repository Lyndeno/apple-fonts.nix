# Fonts sourced from Apple

This flake provides easy access to the Apple fonts listed on their website. Just add it as a font package, then configure your programs to use it.

Packages are also provided that automatically patch the fonts with the [nerd font patcher](https://github.com/ryanoasis/nerd-fonts). This provides a font that includes the most common symbols, suitable for use in the terminal, statusbars, etc.

# Example

In my case, I use [stylix](https://stylix.danth.me/):

```nix
stylix.fonts = {
    serif = {
        package = inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
    };
};
```
