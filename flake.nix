{
  description = "Sandboxed TypeScript runtime for AI coding agents to query AWS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        sandy = pkgs.stdenv.mkDerivation {
          pname = "sandy";
          version = "0.5.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            bun
            nodejs
          ];

          buildPhase = ''
            runHook preBuild

            export HOME=$TMPDIR

            bun install --frozen-lockfile
            bun scripts/pack-embedded.ts
            bun build --compile --target=bun src/main.ts --outfile dist/sandy

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            cp dist/sandy $out/bin/sandy

            runHook postInstall
          '';

          meta = {
            description = "Sandboxed TypeScript runtime for AI coding agents to query AWS";
            homepage = "https://github.com/jamestelfer/sandy";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "sandy";
          };
        };

        default = self.packages.${system}.sandy;
      };
    });
}
