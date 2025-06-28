#!/usr/bin/env -S guix shell guile guile-json guile-gcrypt -- guile --no-auto-compile
!#
(use-modules (guix channels)
             (gnu services)
             (ice-9 match)
             (ice-9 popen)
             (ice-9 rdelim)
             (ice-9 pretty-print)
             (srfi srfi-1)
             (json))

(define BASE-URL "http://nonguix-cuirass.ditigal.xyz")
(define HISTORY-URL
  (string-append BASE-URL
                 "/api/jobs/history?spec=nonguix&names=linux.x86_64-linux&nr=100"))
(define CHANNEL-CONFIGS
  '((guix
     "https://codeberg.org/guix/guix.git"
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")
    (nonguix
     "https://gitlab.com/nonguix/nonguix.git"
     "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
     "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")
    (saayix
     "https://codeberg.org/look/saayix.git"
     "12540f593092e9a177eb8a974a57bb4892327752"
     "3FFA 7335 973E 0A49 47FC  0A8C 38D5 96BE 07D3 34AB"
     "main")
    (pognul
     "https://codeberg.org/ch4og/pognul-guix-channel.git"
     #f
     #f
     "main")))

(define config-root
  (let* ((source-file (current-filename))
         (abs-path (canonicalize-path source-file)))
    (dirname abs-path)))

(define guix
  (string-append "guix time-machine -C " config-root "/channels.scm -- "))

(define priv
  (if (zero? (system "which doas > /dev/null 2>&1")) "doas " "sudo "))

(define (read-all port)
  (let loop ((lines '()))
    (let ((line (read-line port 'concat)))
      (if (eof-object? line)
          (string-join (reverse lines) "")
          (loop (cons line lines))))))

(define (get-last-commit repo)
  (let ((p (open-pipe* OPEN_READ "git" "ls-remote" repo "HEAD")))
    (let ((out (read-line p)))
      (close-pipe p)
      (car (string-split out #\tab)))))

(define (all-jobs-success? jobs-vec)
  (every
   (lambda (job-alist)
     (= (assoc-ref job-alist "status") 0))
   (vector->list jobs-vec)))

(define (get-cuirass-commits)
      (catch #t
        (lambda ()
          (let* ((curl-port (open-pipe* OPEN_READ "curl" "-Ls" HISTORY-URL))
                 (json-str (read-all curl-port))
                 (json-data (call-with-input-string json-str json->scm))
                 (entries (vector->list json-data))
                 (first-good
                  (find
                   (lambda (entry-alist)
                     (all-jobs-success? (assoc-ref entry-alist "jobs")))
                   entries)))
            (close-pipe curl-port)
            (if first-good
                (let* ((eval-id (assoc-ref first-good "evaluation"))
                       (eval-url (string-append BASE-URL "/api/evaluation?id=" (number->string eval-id)))
                       (eval-port (open-pipe* OPEN_READ "curl" "-Ls" eval-url))
                       (eval-json-str (read-all eval-port))
                       (eval-data (call-with-input-string eval-json-str json->scm))
                       (checkouts (assoc-ref eval-data "checkouts")))
                  (close-pipe eval-port)
                  (let ((guix-commit #f)
                        (nonguix-commit #f))
                    (for-each
                     (lambda (co)
                       (let ((channel (assoc-ref co "channel"))
                             (commit (assoc-ref co "commit")))
                         (cond
                          ((string=? channel "guix")
                           (set! guix-commit commit))
                          ((string=? channel "nonguix")
                           (set! nonguix-commit commit)))))
                     (vector->list checkouts))
                    (if (and guix-commit nonguix-commit)
                        (cons guix-commit nonguix-commit)
                        #f)))
                #f)))
        (lambda (key . args)
          #f)))

(define (get-channel-commit channel-name repo-url cuirass-commits)
  (cond
   ((and cuirass-commits (string=? channel-name "guix"))
    (car cuirass-commits))
   ((and cuirass-commits (string=? channel-name "nonguix"))
    (cdr cuirass-commits))
   (else
    (when (and (member channel-name '("guix" "nonguix")) (not cuirass-commits))
      (format #t "Fallback to git ls-remote for ~a channel\n" channel-name))
    (get-last-commit repo-url))))

(define (run cmd)
  (display (string-append "$ " cmd "\n"))
  (let ((status (system (string-append "exec " cmd))))
    (unless (zero? status)
      (format #t "Command failed: ~a (exit code: ~a)\n" cmd status)
      (exit status))))

(define (channel->code ch)
  (let ((name (channel-name ch))
        (url (channel-url ch))
        (branch (channel-branch ch))
        (commit (channel-commit ch))
        (intro (channel-introduction ch)))
    `(channel
       (name (quote ,name))
       (url ,url)
       ,@(if branch `((branch ,branch)) '())
       ,@(if commit `((commit ,commit)) '())
       ,@(if intro
             (let* ((first-commit (channel-introduction-first-signed-commit intro))
                    (config (find (lambda (cfg) (eq? (car cfg) name)) CHANNEL-CONFIGS))
                    (fingerprint (cond
                                   ((match config
                                      ((name url intro-commit fp) fp)
                                      ((name url intro-commit fp branch) fp)
                                      (_ #f))))))
               `((introduction
                   (make-channel-introduction
                     ,first-commit
                     (openpgp-fingerprint ,fingerprint)))))
             '()))))

(define (make-configured-channel config cuirass-commits)
  (match config
    ((name url intro-commit fingerprint . rest)
     (let ((branch (if (null? rest) #f (car rest)))
           (channel-name (if (symbol? name) (symbol->string name) name)))
       (channel
         (name (if (symbol? name) name (string->symbol name)))
         (url url)
         (branch branch)
         (introduction 
           (if (and intro-commit fingerprint)
               (make-channel-introduction
                 intro-commit
                 (openpgp-fingerprint fingerprint))
               #f))
         (commit (get-channel-commit channel-name url cuirass-commits)))))))

(define (channels)
  (let ((cuirass-commits (get-cuirass-commits)))
    (map (lambda (config)
           (make-configured-channel config cuirass-commits))
         CHANNEL-CONFIGS)))

(define (zyztem extra-args)
  (run (string-append priv
                      guix
                      " system reconfigure "
                      (string-join extra-args " ")
                      " "
                      config-root
                      "/system/system.scm"))
  (run "guix pull"))

(define (home extra-args)
  (run (string-append "guix home reconfigure "
                      (string-join extra-args " ")
                      " "
                      config-root
                      "/home/home.scm")))

(define (update)
  (let* ((channels-file (string-append config-root "/channels.scm"))
         (new-channels (channels))
         (new-content (with-output-to-string
                        (lambda ()
                          (display ";; DO NOT EDIT! AUTOGENERATED WITH config.scm")
                          (newline)
                          (display ";; In future I would edit config.scm to use values from here")
                          (newline)
                          (pretty-print `(list ,@(map channel->code new-channels))))))
         (old-content (if (file-exists? channels-file)
                          (call-with-input-file channels-file
                            (lambda (port)
                              (read-all port)))
                          "")))
    
    (when (null? new-channels)
      (format #t "Error: Cannot write empty channels list\n")
      (exit 1))
    
    (if (string=? old-content new-content)
        (format #t "Nothing to do\n")
        (begin
          (with-output-to-file channels-file
            (lambda ()
              (display new-content)))
          (format #t "channels.scm updated\n")))))

(define (main args)
  (let ((cmd (if (null? args) ""
                 (car args)))
        (rest (if (null? args)
                  '()
                  (cdr args))))
    (cond
      ((string=? cmd "system")
       (zyztem rest))
      ((string=? cmd "home")
       (home rest))
      ((string=? cmd "update")
       (update))
      (else (display "Available commands:\n")
            (display "  system [args...]  - reconfigure system\n")
            (display "  home   [args...]  - reconfigure home\n")
            (display "  update            - update channels\n")
            (exit 1)))))

(main (cdr (command-line)))

