(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
             (gnu home services sound)
             (gnu home services desktop)
	     (guix gexp)
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
    (service home-pipewire-service-type)
    (service home-dbus-service-type)
   (simple-service 'create-histfile-dir
		   home-activation-service-type
		   #~(begin
                       (use-modules (guix build utils))
                       (mkdir-p (string-append xdg-data-home "/oils"))))

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
		     (".config/nixpkgs/config.nix" ,(dotfile "nix/nixpkgs-config.nix"))
		     (".config/nix/nix.conf" ,(dotfile "nix/nix.conf"))
		     ))

  		(simple-service 'nix-channel-init
  				home-activation-service-type
  				#~(begin
				    (use-modules (guix gexp))
  				    (system* "nix-channel" "--add" "https://nixos.org/channels/nixpkgs-unstable" "nixpkgs")
  				    (system* "nix-channel" "--update")
				    (system "ln -s \"/nix/var/nix/profiles/per-user/$USER/profile\" ~/.nix-profile"))
		    )
   ))
 
 )
