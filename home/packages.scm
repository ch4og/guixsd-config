(use-modules
 (guix utils)
 (gnu packages)
 (gnu packages wm)
 (nongnu packages nvidia)
 (guix transformations))
(define transform
  (options->transformation
   '((with-graft . "mesa=nvda"))))
(append (map specification->package 
     '("starship"
       "hyprpaper"
       "lazygit"
       "emacs"
       "ncurses"
       "oils"
       "eza"
       "xdg-utils"
       "bat"
       "btop"
       "fastfetch"
       "neovim"
       "kitty"
       "firefox"
       "wl-clipboard"
       "xdg-desktop-portal-hyprland"
       "xdg-desktop-portal-gtk"
       "grim"
       "ripgrep"
       "fd"
       "wireplumber"
       "pipewire"
       "torbrowser"
       "telegram-desktop"
       "zoom"
       "qbittorrent-enhanced"
       "filezilla"
       "libreoffice"
       "mpv"
       "eog"
       "kdenlive"
       "krita"
       "fontforge"
       "file-roller"
       "remmina"
       "virt-manager"
       "heroic-nvidia"
       "file"
       "zoxide"
       "yazi"
       "fzf"
       "zsh"
       "zsh-syntax-highlighting"
       "curl"
       "unzip"
       "zip"
       "font-awesome-nonfree"
       "pavucontrol"
       "nftables"
       "pipewire"
       "wireplumber"
       "blueman"
       "rofi-wayland"
	))
(map transform (map specification->package '("waybar@0.12.0" "swayfx" "ghostty" "hyprland")))
	)
