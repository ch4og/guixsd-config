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
