(use-modules (gnu)
             (nongnu packages linux)
             (gnu system nss)
             (nongnu system linux-initrd)
             (nongnu packages nvidia)
             (nongnu services nvidia)
             (gnu services desktop)
             (gnu services dbus)
             (gnu services ssh)
             (gnu services networking)
             (gnu services xorg)
             (guix gexp)
             (guix utils)
             (gnu services sysctl)
             (srfi srfi-1)
             (guix packages)
             (guix channels)
             (gnu system setuid)
             (gnu services nix)
	     (gnu packages package-management)
             ;; WIP
             ;;
             ;; (pognul services ly)
             (guix build syscalls))

(define config-root
  (let* ((source-file (current-filename))
         (abs-path (canonicalize-path source-file)))
    (dirname abs-path)))

(define my-channels
  (load (string-append config-root "/../channels.scm")))

(operating-system
 (kernel linux)
 (kernel-arguments '("modprobe.blacklist=nouveau" "nvidia_drm.modeset=1"
                     "nvidia_drm.fbdev=0" "loglevel=4" "mitigations=off"))
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (host-name "noko")
 (timezone "Europe/Moscow")
 (locale "en_US.utf8")

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/boot"))
              (keyboard-layout (keyboard-layout "us"))))
 (file-systems (append (list (file-system
                              (device (uuid "B045-64D9"
                                            'fat))
                              (mount-point "/boot")
                              (type "vfat"))
                             (file-system
                              (device (uuid
                                       "f5c02db4-68f9-425d-91c4-389ba02c3310"
                                       'btrfs))
                              (mount-point "/")
                              (type "btrfs")
                              (options "subvol=root,compress=zstd"))
                             (file-system
                              (device (uuid
                                       "f5c02db4-68f9-425d-91c4-389ba02c3310"
                                       'btrfs))
                              (mount-point "/home")
                              (type "btrfs")
                              (options "subvol=home,compress=zstd"))
                             (file-system
                              (device (uuid
                                       "f5c02db4-68f9-425d-91c4-389ba02c3310"
                                       'btrfs))
                              (mount-point "/gnu/store")
                              (type "btrfs")
                              (options "subvol=gnu-store,compress=zstd"))
                             ;; Since `nix-service-type` remounts the Nix store as read-only, this code can't be used directly.
                             ;; Similarly, manually mounting `/nix` won't work either, as Guix sometimes fails to unmount
                             ;; certain partitions cleanly on reboot. This can result in data loss and corruption of the store.
                             ;; Reference: https://issues.guix.gnu.org/77963
                             ;;
                             ;; (file-system
                             ;; (device
                             ;; (uuid "f5c02db4-68f9-425d-91c4-389ba02c3310" 'btrfs))
                             ;; (mount-point "/nix/store")
                             ;; (type "btrfs")
                             ;; (options "subvol=nix-store,compress=zstd"))
                             ) %base-file-systems))

 (users (cons (user-account
               (name "ch")
               (comment "ch4og")
               (group "users")
               (shell (file-append (specification->package "zsh") "/bin/zsh"))
               (supplementary-groups '("wheel" "audio" "video")))
              %base-user-accounts))

 (packages (remove (lambda (pkg)
                     (string=? (package-name pkg) "nano"))
                   (append (map specification->package
                                '("git" "vim" "opendoas" "nix" "swayfx"
                                  "hyprland")) %base-packages)))

 (setuid-programs (append (list (setuid-program (program (file-append (specification->package
                                                                       "opendoas")
								      "/bin/doas"))))
                          %setuid-programs))

 (services
  (append (list (service openssh-service-type
                         (openssh-configuration (openssh (specification->package
                                                          "openssh-sans-x"))
                                                (port-number 2222)))
                (service nvidia-service-type)
                (simple-service 'doas-config-file etc-service-type
                                (list `("doas.conf" ,(plain-file "doas.conf"
								 "permit persist :wheel\n"))))
                (service nix-service-type)
                (service bluetooth-service-type)
                ;; WIP
                ;;
                ;; (service ly-service-type
                ;; (ly-configuration
                ;; (tty 9)
                ;; (auto-login? #f)
                ;; (default-user #f)))
                )

          (modify-services %desktop-services
			   (guix-service-type config =>
					      (guix-configuration (inherit config)
								  (channels my-channels)
								  (guix (guix-for-channels my-channels))
								  (substitute-urls (list
										    "https://mirror.sjtu.edu.cn/guix"
										    "https://bordeaux.guix.gnu.org"
										    "https://nonguix-proxy.ditigal.xyz"))
								  (authorized-keys (append (list
											    (plain-file
											     "non-guix.pub"
											     "(public-key (ecc
											     (curve Ed25519) 
											     (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
											   %default-authorized-guix-keys))))
			   (delete gdm-service-type)
			   (sysctl-service-type config =>
						(sysctl-configuration (settings (append '(("vm.max_map_count" . "1048576")
											  ("net.ipv6.conf.all.disable_ipv6" . "1"))
											%default-sysctl-settings)))))))
 (name-service-switch %mdns-host-lookup-nss))
