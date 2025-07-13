;;; Copyright © 2025 Nikita Mitasov <mitanick@ya.ru>
(define-module (modules packages)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (gnu system))

(define-public sys-pkgs

  (remove (lambda (pkg)
            (string=? (package-name pkg) "nano"))
          (append (map specification->package
		       '("git" "vim" "nix" "hyprland")) %base-packages)))
