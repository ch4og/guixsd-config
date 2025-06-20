# ch4og's Dotfiles (Guix Home)

Personal dotfiles managed with **GNU Guix Home** and organized using the [**GNU Stow**](https://www.gnu.org/software/stow/manual/stow.html#Introduction) layout.

**Each subdirectory here is a package**, auto-linked to `$HOME` via `home-dotfiles-service-type`.

## Stow Mapping Example

| Source| Dest in `$HOME`|
|-|-|
|`sway/.config/sway/config`|`~/.config/sway/config`|
|`zsh/.zshrc`|`~/.zshrc`|
|`rofi/.local/share/rofi/themes/custom.rasi`|`~/.local/share/rofi/themes/custom.rasi`|

#### If you want to use it with Guix Home:
```scheme
(service home-dotfiles-service-type
  (home-dotfiles-configuration
    (directories '("./dotfiles"))
    (layout 'stow)
    (excluded '(".*~" ".*\\.swp" "\\.git" "\\.gitignore" "README.md"))
    (packages '("zsh" "sway" "other-package-name"))))
```

#### Manual Usage (non-Guix):
```sh
cp dotfiles/zsh/.zshrc ~/.zshrc
cp dotfiles/rofi/.local/share/rofi/themes/custom.rasi ~/.local/share/rofi/themes/custom.rasi
```
