;;; Copyright © 2025 Nikita Mitasov <mitanick@ya.ru>
(use-modules
 (guix utils)
 (gnu packages)
 (nongnu packages nvidia)
 (guix transformations))

(define transform
  (options->transformation
   '((with-graft . "mesa=nvda"))))

(map transform 
     (map specification->package 
	  '("git" "vim" "nix" "hyprland")))
