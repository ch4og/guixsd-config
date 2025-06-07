(use-modules (gnu home)
             (gnu packages)
             (gnu home services)
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
 (packages 
  (map replace-mesa 
       (load "packages.scm")))

 (services
  (list
   (simple-service 'create-histfile-dir
		   home-activation-service-type
		   #~(begin
                       (use-modules (guix build utils))
                       (mkdir-p (string-append xdg-data-home "/oils"))))

   (simple-service 'dotfiles
		   home-files-service-type 
		   `((".config/oils/oshrc" ,(dotfile "oils/oshrc"))
		     (".zshrc" ,(dotfile "zsh/zshrc"))
		     (".zprofile" ,(dotfile "zsh/zprofile"))
		     (".config/starship.toml", (dotfile "starship/starship.toml"))
		     (".config/fastfetch/config.jsonc" ,(dotfile "fastfetch/config.jsonc"))
		     (".config/kitty/kitty.conf" ,(dotfile "kitty/kitty.conf"))
		     (".config/hypr/hyprpaper.conf" ,(dotfile "hypr/hyprpaper.conf"))
		     (".config/fastfetch/shika_guix.png" ,(dotfile "fastfetch/shika_guix.png"))
		     ))
   ))
 
 )
