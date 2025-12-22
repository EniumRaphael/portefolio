{
  description = "Flake for portefolio";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        tmux-setup = pkgs.writeShellScriptBin "tmux-setup" ''
          #!/usr/bin/env sh
          SESSION="transcendance"
          DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          if ! tmux has-session -t $SESSION 2>/dev/null; then
            tmux new-session -d -s $SESSION -c "$DIR" -n dev
            tmux send-keys -t $SESSION:0 'vim' C-m
            tmux split-window -h -p 30 -t $SESSION:0 -c "$DIR"
            tmux send-keys -t $SESSION:0.1 'exec zsh' C-m
            tmux split-window -v -p 30 -t $SESSION:0.1 -c "$DIR"
            tmux send-keys -t $SESSION:0.2 'watch -n0.5 npx --prefix=./src/ eslint .' C-m
            tmux new-window -t $SESSION:1 -n git -c "$DIR"
            tmux send-keys -t $SESSION:1 'lazygit' C-m
            tmux new-window -t $SESSION:2 -n docker -c "$DIR"
            tmux send-keys -t $SESSION:2 'lazydocker' C-m
          fi
          tmux select-window -t $SESSION:0
          tmux select-pane -t $SESSION:0.0
          tmux attach -t $SESSION
        '';
      in {
        devShell = pkgs.mkShellNoCC {
          packages = with pkgs; [
            lazydocker
            nodejs_22
            pnpm
            tmux-setup
            pnpm
          ];
        };
      }
    );
}
