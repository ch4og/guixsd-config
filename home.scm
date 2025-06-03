(use-modules (gnu home)
             (gnu packages)
             (gnu packages base)
             (gnu home services)
             (gnu home services shells)
             (guix gexp))

(home-environment
 (packages
  (map specification->package
       '("neofetch" "zsh" "starship" "hyprpaper" "lazygit")))

 (services
  (list
      (simple-service 'fastfetch-logo
		   home-xdg-configuration-files-service-type
		   (list
		 	    `("fastfetch/shika_guix.png"
			   	,(local-file "assets/shika_guix.png"))))

      (simple-service 'fastfetch-config
                   home-xdg-configuration-files-service-type
                   (list 
			    `("fastfetch/config.jsonc"
                                    ,(plain-file "fastfetch.jsonc"
"
{
  \"logo\": {
    \"height\": 8,
    \"padding\": {
      \"left\": 3,
      \"top\": 1
    },
    \"source\": \"~/.config/fastfetch/shika_guix.png\",
    \"type\": \"kitty\",
    \"width\": 33
  },
  \"modules\": [
    {
      \"format\": \"\",
      \"type\": \"custom\"
    },
    \"title\",
    \"separator\",
    {
      \"key\": \"os\",
      \"type\": \"os\"
    },
    {
      \"key\": \"kernel\",
      \"type\": \"kernel\"
    },
    {
      \"key\": \"up\",
      \"type\": \"uptime\"
    },
    {
      \"key\": \"wm\",
      \"type\": \"wm\"
    },
    {
      \"key\": \"shell\",
      \"type\": \"shell\"
    },
    {
      \"key\": \"term\",
      \"type\": \"terminal\"
    },
    {
      \"symbol\": \"circle\",
      \"type\": \"colors\"
    }
  ]
}
"))))
   (simple-service 'kitty-config
                   home-xdg-configuration-files-service-type
                   (list `("kitty/kitty.conf"
                                    ,(plain-file "kitty.conf"
"
background_opacity 0.8
background #1a1b26
font_size 12
font_family ComicCode Nerd Font
"))))
   (simple-service 'hyprpaper-config
                   home-xdg-configuration-files-service-type
                   (list `("hypr/hyprpaper.conf"
                                    ,(plain-file "hyprpaper.conf"
"
preload=~/Pictures/wallhaven-expj3o.jpg
wallpaper=,~/Pictures/wallhaven-expj3o.jpg
"))))
   (simple-service 'starship
		   home-xdg-configuration-files-service-type
		   (list `("starship.toml"
			   	,(plain-file "starship.toml"
"
add_newline = true
format = \"\"\"
 \
$username\
$hostname\
$localip\
$shlvl\
$singularity\
$kubernetes\
$directory\
$vcsh\
$fossil_branch\
$fossil_metrics\
$git_branch\
$git_commit\
$git_state\
$git_metrics\
$git_status\
$hg_branch\
$pijul_channel\
$docker_context\
$package\
$c\
$cmake\
$cobol\
$daml\
$dart\
$deno\
$dotnet\
$elixir\
$elm\
$erlang\
$fennel\
$gleam\
$golang\
$guix_shell\
$haskell\
$haxe\
$helm\
$java\
$julia\
$kotlin\
$gradle\
$lua\
$nim\
$nodejs\
$ocaml\
$opa\
$perl\
$php\
$pulumi\
$purescript\
$python\
$quarto\
$raku\
$rlang\
$red\
$ruby\
$rust\
$scala\
$solidity\
$swift\
$terraform\
$typst\
$vlang\
$vagrant\
$zig\
$buf\
$nix_shell\
$conda\
$meson\
$spack\
$memory_usage\
$aws\
$gcloud\
$openstack\
$azure\
$nats\
$direnv\
$env_var\
$mise\
$crystal\
$custom\
$sudo\
$cmd_duration\
$line_break\
$jobs\
$time\
$status\
$os\
$container\
$netns\
$shell\
$character
\"\"\"
palette = \"base16\"

[palettes.base16]
base00 = \"#1a1b26\"
base01 = \"#16161e\"
base02 = \"#2f3549\"
base03 = \"#444b6a\"
base04 = \"#787c99\"
base05 = \"#a9b1d6\"
base06 = \"#cbccd1\"
base07 = \"#d5d6db\"
base08 = \"#c0caf5\"
base09 = \"#a9b1d6\"
base0A = \"#0db9d7\"
base0B = \"#9ece6a\"
base0C = \"#b4f9f8\"
base0D = \"#2ac3de\"
base0E = \"#bb9af7\"
base0F = \"#f7768e\"
base10 = \"#1a1b26\"
base11 = \"#1a1b26\"
base12 = \"#c0caf5\"
base13 = \"#0db9d7\"
base14 = \"#9ece6a\"
base15 = \"#b4f9f8\"
base16 = \"#2ac3de\"
base17 = \"#bb9af7\"
black = \"#1a1b26\"
blue = \"#2ac3de\"
bright-black = \"#444b6a\"
bright-blue = \"#2ac3de\"
bright-cyan = \"#b4f9f8\"
bright-green = \"#9ece6a\"
bright-magenta = \"#bb9af7\"
bright-purple = \"#bb9af7\"
bright-red = \"#c0caf5\"
bright-white = \"#d5d6db\"
bright-yellow = \"#0db9d7\"
brown = \"#f7768e\"
cyan = \"#b4f9f8\"
green = \"#9ece6a\"
magenta = \"#bb9af7\"
orange = \"#a9b1d6\"
purple = \"#bb9af7\"
red = \"#c0caf5\"
white = \"#a9b1d6\"
yellow = \"#0db9d7\"
"))))
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc
              (list
               (plain-file "rc.zsh"
                           (string-join '("alias guix='guix time-machine -C ~/Code/Guix/guix-config/channels.scm --'" "eval \"$(starship init zsh)\"" "fastfetch") "\n"))))
	      (zshenv
              (list
               (plain-file "env.zsh"
                           (string-join '("setopt +o nomatch") "\n")))))
   )))
   
)
