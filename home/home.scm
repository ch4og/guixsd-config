(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
             (gnu home services sound)
             (gnu home services desktop)
	     (guix gexp)
	     (guix packages)
	     (guix download)
	     (nongnu packages nvidia))

(define (home-dir) 
  (getenv "HOME"))

(define (xdg-data-home)
  (or (getenv "XDG_DATA_HOME")
      (string-append home-dir "/.local/share")))

(define config-root
  (let* ((source-file (current-filename))
         (abs-path (canonicalize-path source-file)))
    (dirname abs-path)))

(define (dotfile path)
  (local-file (string-append  config-root "/dotfiles/" path)))

(home-environment
 (packages (load "packages.scm"))

 (services
  (list
   (service home-dbus-service-type)

   (simple-service
    'env-vars-service
    home-environment-variables-service-type
    '(("TERM" . "xterm-256color")("NIXPKGS_ALLOW_UNFREE" . "1")))

   (simple-service 'dotfiles
		   home-files-service-type 
		   `((".config/oils/oshrc" ,(dotfile "oils/oshrc"))
		     (".zshrc" ,(dotfile "zsh/zshrc"))
		     (".zprofile" ,(dotfile "zsh/zprofile"))
		     (".config/starship.toml", (dotfile "starship/starship.toml"))
		     (".config/fastfetch/config.jsonc" ,(dotfile "fastfetch/config.jsonc"))
		     (".config/kitty/kitty.conf" ,(dotfile "kitty/kitty.conf"))
		     (".config/sway/config" ,(dotfile "sway/config"))
		     (".config/fastfetch/shika_guix.png" ,(dotfile "fastfetch/shika_guix.png"))
		     (".config/nvim/init.lua" ,(dotfile "nvim/init.lua"))
		     (".config/waybar/config.jsonc" ,(dotfile "waybar/config.jsonc"))
		     (".config/waybar/style.css" ,(dotfile "waybar/style.css"))
		     (".config/nixpkgs/config.nix" ,(dotfile "nix/nixpkgs-config.nix"))
		     (".config/nix/nix.conf" ,(dotfile "nix/nix.conf"))
		     (".config/rofi/config.rasi" ,(dotfile "rofi/config.rasi"))
		     (".local/share/rofi/themes/custom.rasi" ,(dotfile "rofi/custom.rasi"))
		     (".config/ghostty/config" ,(dotfile "ghostty/config"))
		     (".config/ghostty/themes/ch4og" ,(dotfile "ghostty/themes/ch4og"))
		     ))

   (simple-service 'nix-channel-init
  		   home-activation-service-type
  		   #~(begin
		       (use-modules (guix gexp))
  		       (system* "nix-channel" "--add" "https://nixos.org/channels/nixpkgs-unstable" "nixpkgs")
  		       (system* "nix-channel" "--update")
		       )
		   ))
  
  )
