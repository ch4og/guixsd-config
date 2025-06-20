(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services dotfiles)
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
  (local-file (string-append config-root "/dotfiles/" path)))

(home-environment
 (packages (load "packages.scm"))

 (services
  (list (service home-dbus-service-type)

        (simple-service 'env-vars-service
                        home-environment-variables-service-type
                        '(("TERM" . "xterm-256color")
                          ("NIXPKGS_ALLOW_UNFREE" . "1")))

        (service home-dotfiles-service-type
                 (home-dotfiles-configuration (directories '("./dotfiles"))
                                              (layout 'stow)
					      (excluded '(".*~" ".*\\.swp" "\\.git" "\\.gitignore" "README.md"))
                                              (packages '("zsh" "starship"
                                                          "fastfetch"
                                                          "sway"
                                                          "nvim"
                                                          "waybar"
                                                          "nix"
                                                          "rofi"
                                                          "ghostty"))))

        (simple-service 'nix-channel-init home-activation-service-type
                        #~(begin
                            (use-modules (guix gexp))
                            (system* "nix-channel" "--add"
				     "https://nixos.org/channels/nixpkgs-unstable"
				     "nixpkgs")
                            (system* "nix-channel" "--update"))))))
