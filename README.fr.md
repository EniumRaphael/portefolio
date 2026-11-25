# CV portfolio adapté à l'impression

[🇬🇧 English version](README.md)

Un site de portfolio/CV en ligne construit avec Astro, conçu pour présenter un profil de façon claire, élégante et adaptée à l'impression (une page A4 en PDF) :
  - parcours académique et professionnel,
  - expériences (emploi, bénévolat, projets),
  - compétences techniques,
  - langues,
  - et projets personnels.

Tout (environnement de développement, contenu, build et déploiement) passe par les flakes [Nix](https://nixos.org/).

### Organisation

| Chemin | Rôle |
| --- | --- |
| `flake.nix` | Shell de développement, package et module NixOS |
| `nix/cv.nix` | Le contenu du CV, un attrset [JSON Resume](https://jsonresume.org/schema/) |
| `nix/package.nix` | Construit le site statique pour un `cv` et un `siteUrl` donnés |
| `nix/module.nix` | Module NixOS qui sert le site avec nginx |

`cv.json` est généré depuis `nix/cv.nix` (par le shell de développement et par le package), il n'est pas versionné.

### Développement

Entrer dans le shell de développement (Node.js, pnpm, tmux, lazygit), qui génère aussi `cv.json` :
```bash
git clone https://github.com/EniumRaphael/portefolio
cd portefolio
nix develop
pnpm install
pnpm dev    # Mode watch pour voir les changements
```

`tmux-setup` ouvre une session tmux prête à l'emploi (éditeur, serveur de dev, git).

### Modifier le contenu

Modifier `nix/cv.nix`, puis relancer `nix develop` pour régénérer `cv.json`.

Thèmes disponibles (`basics.theme`) :
  - default
  - blue
  - cyber
  - green
  - red
  - Catppuccin Mocha (`mocha`)
  - TokyoNight (`tokyonight`)

### Build

```bash
nix build   # Le site est dans ./result
```

L'URL canonique (canonical, `og:url`, JSON-LD) est transmise au build via `SITE_URL`.

### Déployer avec le module NixOS

Un build et une URL canonique par domaine :
```nix
{
  inputs.portefolio.url = "github:EniumRaphael/portefolio";
  # ...
  imports = [ inputs.portefolio.nixosModules.default ];
  services.portefolio = {
    enable = true;
    domains = [ "example.net" "example.com" ];
    # cv = { ... };  # optionnel, par défaut nix/cv.nix
  };
}
```

Autres options : `user`, `group`, `createUser`, `forceSSL` et `enableACME` (toutes activées par défaut sauf les noms d'utilisateur/groupe).

Basé sur [Smilesharks/dev-portfolio](https://github.com/Smilesharks/dev-portfolio), avec des personnalisations pour mon propre portfolio.
