(define-module (POgnuL packages lazygit)
  #:use-module (guix packages)
  #:use-module (guix build-system go)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages golang)
  #:use-module (guix licenses))

(define-public lazygit
  (package
    (name "lazygit")
    (version "0.51.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/jesseduffield/lazygit/archive/refs/tags/v" version ".tar.gz"))
              (sha256 (base32 "01imgysvqaym2fw5dwfp1xd7jfax424sxslb53cvyp9piacb6zs6"))
              (file-name (git-file-name name version))))
    (build-system go-build-system)
    (arguments
     (list #:import-path "github.com/jesseduffield/lazygit"
	   #:go go-1.24
           #:tests? #f
           #:install-source? #f))
    (home-page "https://github.com/jesseduffield/lazygit")
    (synopsis "Simple terminal UI for git commands")
    (description "Simple terminal UI for git commands")
    (license expat)))
