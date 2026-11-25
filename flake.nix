{
  description = "Flake for portefolio";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    claude-cage.url = "github:EniumRaphael/claude-cage";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      claude-cage,
    }:
    let
      cv = import ./nix/cv.nix;
      mkSite = pkgs: pkgs.callPackage ./nix/package.nix { };
    in
    {
      nixosModules.default = import ./nix/module.nix { inherit mkSite; };
    }
    // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cvJson = pkgs.writeText "cv.json" (builtins.toJSON cv);
        tmux-setup = pkgs.writeShellApplication {
          name = "tmux-setup";
          runtimeInputs = [
            pkgs.tmux
            pkgs.git
          ];
          text = ''
            SESSION="portefolio"
            DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
            if ! tmux has-session -t "$SESSION" 2>/dev/null; then
              tmux new-session -d -s "$SESSION" -c "$DIR" -n dev
              tmux send-keys -t "$SESSION:dev" 'vim' C-M
              shell=$(tmux split-window -h -l 30% -t "$SESSION:dev" -c "$DIR" -P -F '#{pane_id}')
              claude=$(tmux split-window -v -l 30% -t "$shell" -c "$DIR" -P -F '#{pane_id}')
              tmux send-keys -t "$claude" 'sleep 0.2 ; claude' C-M
              tmux new-window -t "$SESSION" -n git -c "$DIR"
              tmux send-keys -t "$SESSION:git" 'lazygit' C-M
              tmux new-window -t "$SESSION" -n logs -c "$DIR"
              tmux send-keys -t "$SESSION:logs" 'pnpm dev' C-M
            fi
            tmux select-window -t "$SESSION:dev"
            tmux select-pane -t "$SESSION:dev.0"
            if [ -n "''${TMUX:-}" ]; then tmux switch-client -t "$SESSION"; else tmux attach -t "$SESSION"; fi
          '';
        };
      in
      {
        packages.default = mkSite pkgs {
          inherit cv;
          siteUrl = "https://example.com";
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            lazygit
            nodejs_22
            tmux-setup
            pnpm
            claude-cage.packages.${system}.default
          ];
          shellHook = ''
            install -m 644 ${cvJson} cv.json
            export CLAUDE_CAGE_ROOT="$PWD"
          '';
        };
      }
    );
}
