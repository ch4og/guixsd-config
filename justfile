substituters := 'https://bordeaux.guix.gnu.org https://ci.guix.trop.in https://nonguix-proxy.ditigal.xyz'

guix := 'guix time-machine -C channels.scm -- '

# List all commands
default:
    @just --list

# Prebuild step
pre:
    git add .

# Rebuild system with full substituters
system: pre
    sudo {{guix}} system reconfigure system.scm

home: pre
    {{guix}} home reconfigure home.scm

# Update channels (runs your guile script)
up:
    GUILE_AUTO_COMPILE=0 guile update.scm

# add home and fmt/fix
