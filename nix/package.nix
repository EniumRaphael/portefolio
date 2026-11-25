# `cv`: attrset (JSON Resume schema); `siteUrl`: public URL (canonical, og:url, JSON-LD).
{
  lib,
  stdenvNoCC,
  nodejs_22,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  writeText,
}:
{
  cv,
  siteUrl,
}:
let
  src = lib.cleanSourceWith {
    src = ../.;
    filter =
      path: type:
      !(builtins.elem (baseNameOf path) [
        "node_modules"
        "dist"
        ".astro"
        ".direnv"
        ".git"
        "nix"
        "cv.json"
        "flake.nix"
        "flake.lock"
      ]);
  };
  cvJson = writeText "cv.json" (builtins.toJSON cv);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "portefolio";
  version = "0.0.1";
  inherit src;

  nativeBuildInputs = [
    nodejs_22
    pnpm
    pnpmConfigHook
  ];
  disallowedReferences = [
    nodejs_22
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-Bsb0KCHlPaPv7haDcB4vAWAl3qC/49b2KOxPmfu3smA=";
  };

  env.SITE_URL = siteUrl;

  # `@cv` (tsconfig) points to ./cv.json: generate it from the Nix config
  preBuild = ''
    cp ${cvJson} cv.json
  '';

  buildPhase = ''
    runHook preBuild
    pnpm exec astro build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';
})
