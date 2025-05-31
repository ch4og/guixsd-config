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
	     (gnu services lightdm))

(operating-system
  (kernel linux)
    (kernel-arguments '("modprobe.blacklist=nouveau"
                      "nvidia_drm.modeset=1"
		      "nvidia_drm.fbdev=0"
		      ))
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (host-name "pc2")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot"))
		(keyboard-layout (keyboard-layout "us"))))
  (file-systems (append (list (file-system
                        (device (uuid "B045-64D9" 'fat))
                        (mount-point "/boot")
                        (type "vfat"))
		      (file-system
			(device (uuid "f5c02db4-68f9-425d-91c4-389ba02c3310" 'btrfs))
			(mount-point "/")
			(type "btrfs")
			(options "subvol=root,compress=zstd"))
		      (file-system
			(device (uuid "f5c02db4-68f9-425d-91c4-389ba02c3310" 'btrfs))
			(mount-point "/home")
			(type "btrfs")
			(options "subvol=home,compress=zstd"))
		      (file-system
			(device (uuid "f5c02db4-68f9-425d-91c4-389ba02c3310" 'btrfs))
			(mount-point "/var/log")
			(type "btrfs")
			(options "subvol=log,compress=zstd"))
		      (file-system
			(device (uuid "f5c02db4-68f9-425d-91c4-389ba02c3310" 'btrfs))
			(mount-point "/gnu")
			(type "btrfs")
			(options "subvol=gnu,compress=zstd")))
                      %base-file-systems))

  (users (cons (user-account
                (name "ch")
                (comment "ch4og")
                (group "users")
		(shell (file-append (specification->package "zsh") "/bin/zsh"))
                (supplementary-groups '("wheel"
                                        "audio" "video")))
               %base-user-accounts))

  (packages (append (map replace-mesa (map specification->package
		 '("neovim" "fastfetch" "hyprland" "waybar" "kitty" "zsh" "just" "git" "firefox")))
		    %base-packages))

  (services (append (list(service dhcp-client-service-type)
                          (service openssh-service-type
                                   (openssh-configuration
                                    (openssh (specification->package "openssh-sans-x"))
                                    (port-number 2222)))
			     (service nvidia-service-type)

				    (service lightdm-service-type
  (lightdm-configuration
    (lightdm (replace-mesa (specification->package "lightdm")))
    (seats (list (lightdm-seat-configuration (name "*")(user-session "Hyprland")))
   )))
          (service polkit-service-type)
	     (service elogind-service-type)
	     (service ntp-service-type)
	  )

			  (modify-services %base-services
             (guix-service-type config => (guix-configuration
               (inherit config)
               (substitute-urls
                (list "https://bordeaux.guix.gnu.org" 
		      "https://ci.guix.trop.in" 
		      "https://nonguix-proxy.ditigal.xyz"))
               (authorized-keys
                (append (list (plain-file "non-guix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                  %default-authorized-guix-keys))))
	     )))
	    (name-service-switch %mdns-host-lookup-nss))
