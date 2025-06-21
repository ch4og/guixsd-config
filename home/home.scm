(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
	     (gnu services)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services dotfiles)
             (guix gexp)
             (guix packages)
             (guix download)
             (nongnu packages nvidia)
             (gnu home services shepherd))

(define (home-dir)
  (getenv "HOME"))

(define (xdg-data-home)
  (or (getenv "XDG_DATA_HOME")
      (string-append home-dir "/.local/share")))

(define config-root
  (let* ((source-file (current-filename))
         (abs-path (canonicalize-path source-file)))
    (dirname abs-path)))

(home-environment
 (packages (load "packages.scm"))

 (services
  (append (list (service home-dbus-service-type)
        (service home-pipewire-service-type)

        (simple-service 'env-vars-service
                        home-environment-variables-service-type
                        '(("TERM" . "xterm-256color")
                          ("NIXPKGS_ALLOW_UNFREE" . "1")))

        (service home-dotfiles-service-type
                 (home-dotfiles-configuration (directories '("./dotfiles"))
                                              (layout 'stow)
                                              (packages '("fastfetch"
                                                          "ghostty"
                                                          "nix"
                                                          "nvim"
                                                          "rofi"
                                                          "starship"
                                                          "sway"
                                                          "waybar"
                                                          "zsh"))))

        (simple-service 'nix-channel-init home-activation-service-type
                        #~(begin
                            (use-modules (guix gexp))
                            (system
                             "nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs")
                            (system "nix-channel --update"))))
	  %base-home-services)))
