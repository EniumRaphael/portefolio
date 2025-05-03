{
	description = "Flake with latest Node.js and pnpm";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem (system:
			let
			pkgs = import nixpkgs { inherit system; };
			nodejs = pkgs.nodejs;
			pnpm = pkgs.pnpm;
			in {
				packages.default = pkgs.writeShellApplication {
					name = "pnpm-dev";
					runtimeInputs = [ nodejs pnpm ];
					text = ''
						exec pnpm dev "$@"
					'';
				};

				devShells.default = pkgs.mkShell {
					buildInputs = [ nodejs pnpm ];
				};
			}
		);
}
