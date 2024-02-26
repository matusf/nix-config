# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  xdgVars = {
    JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
    DOT_SAGE = "$XDG_CONFIG_HOME/sage";
    STACK_ROOT = "$XDG_DATA_HOME/stack";
    ASDF_CONFIG_FILE = "$XDG_CONFIG_HOME/asdf";
    ASDF_DATA_DIR = "$XDG_DATA_HOME/asdf";
    ASDF_DIR = "$ASDF_DATA_DIR";
    TEXMFHOME = "$XDG_DATA_HOME/texmf";
    TEXMFVAR = "$XDG_CACHE_HOME/texlive/texmf-var";
    TEXMFCONFIG = "$XDG_CONFIG_HOME/texlive/texmf-config";
    CABAL_CONFIG = "$XDG_CONFIG_HOME/cabal/config";
    CABAL_DIR = "$XDG_CACHE_HOME/cabal";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    BASH_COMPLETION_USER_FILE = "$XDG_CONFIG_HOME/bash-completion/bash_completion";
    DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
    _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java'';
    VAGRANT_HOME = "$XDG_DATA_HOME/vagrant";
    VAGRANT_ALIAS_FILE = "$XDG_DATA_HOME/vagrant/aliases";
    ELM_HOME = "$XDG_CONFIG_HOME/elm";
    VIRTUALFISH_HOME = "$XDG_DATA_HOME/virtualfish";
    LESSHISTFILE = "$XDG_STATE_HOME/less/history";
    PYTHONPYCACHEPREFIX = "$XDG_CACHE_HOME/cpython/";
    PYTHONUSERBASE = "$XDG_DATA_HOME/cpython";
    MYPY_CACHE_DIR = "$XDG_CACHE_HOME/mypy";
  };

  envVars = {
    EDITOR = "vim";
    VISUAL = "vim";
    SYSTEMD_EDITOR = "vim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";

    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_DIRS = "/usr/local/share/:/usr/share/:/var/lib/snapd/desktop/:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";

    # DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";

    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "matus";
    homeDirectory = "/home/matus";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    htop
    strace
    jq
    vim
    podman
    bat
    ripgrep
    ripgrep-all
    tealdeer

    # Python development
    python311Packages.bpython
    ruff
    poetry
    mypy

    # Rust development
    rustc
    cargo
    clippy
    rustfmt

    # Nix development
    # nixd
    alejandra

    # Work
    glab
    kustomize
    kubernetes-helm
    k9s

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # You can also create simple shell scripts directly inside your
    # configuration. For example, this adds a command 'my-hello' to your
    # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/fish/functions".source = fish/functions;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matus/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = xdgVars // envVars;
  home.sessionPath = ["$HOME/.local/bin" "$CARGO_HOME/bin" "$XDG_DATA_HOME/go"];

  programs = {
    home-manager.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # disable greeting
      '';
      plugins = [
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "goto";
          src = pkgs.fetchFromGitHub {
            owner = "matusf";
            repo = "goto";
            rev = "3cac1540d45e9a711f8831a928cfbb94f7fa7b5a";
            sha256 = "4iiAKDp+O0aY3PgHFUH8qBI5MUE9E/Cf52ChcrsXasc=";
          };
        }
      ];
      shellAbbrs = {
        ga = "git add";
        gs = "git status";
        gc = "git commit -m";
        gca = "git commit --amend -S -C HEAD";
        gp = "git push";
        gcl = "git clone --recursive";
        gpl = "git pull";
        gch = "git checkout";
        gcn = "git checkout -b";
        gb = "git branch";
        gd = "git diff";
        gds = "git diff --staged";
        gaa = "git add .";
        gcm = "git checkout master || git checkout main";
        gl = "git log --oneline";
      };
      shellAliases = {
        l = "ls -CFlh --hyperlink=auto";
        ll = "l -a";
        rm = "gio trash";
        "..." = "cd ../..";
        xpy = "chmod +x *.py";
        g = "goto";
        tl = "tldr";
        o = "xdg-open";
        code = "codium";
        top = "htop";
        wget = "wget --no-hsts";
        glp = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        py = "bpython";
        jwt-decode = "cut -d. -f2 | base64 -d | jq";
        b64 = "base64";
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
      ];
      keybindings = [
        {
          key = "ctrl+tab";
          command = "workbench.action.nextEditor";
        }
        {
          key = "ctrl+shift+tab";
          command = "workbench.action.previousEditor";
        }
      ];
    };
    direnv = {
      enable = true;
    };

    git = {
      enable = true;
      aliases = {
        ch = "checkout";
        cb = "checkout -b";
        rb = "rebase";
        rbi = "rebase -i";
        rba = "rebase --abort";
        rbc = "rebase --continue";
        identity = ''! git config user.name \"$(git config user.$1.name)\"; git config user.email \"$(git config user.$1.email)\"; git config user.signingkey \"$(git config user.$1.signingkey)\"; :'';
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          syntax-theme = "Monokai Extended";
        };
      };
      signing = {
        key = null;
        signByDefault = true;
      };
      ignores = [
        ".mypy_cache/"
        ".ruff_cache/"
        ".python-version"
        ".vscode/"
        ".venv"
        ".env"
        ".coverage"
        ".cache"
        "*.o"
        "build"
        "htmlcov"
        ".direnv"
      ];
      extraConfig = {
        user = {
          useConfigOnly = true;
          github = {
            name = "Matúš Ferech";
            email = "matus.ferech@gmail.com";
            signingkey = "15EDB1A9BD707CEC";
          };
          pan-net = {
            name = "Matúš Ferech";
            email = "matus.ferech@pan-net.eu";
            signingkey = "15EDB1A9BD707CEC";
          };
        };
        color.status = {
          untracked = "yellow";
        };
        init = {
          defaultBranch = "master";
        };
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
