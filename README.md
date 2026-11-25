# Print-friendly portfolio CV

[🇫🇷 Version française](README.fr.md)

An online portfolio/resume website built with Astro, designed to present in a clear, elegant, and print-friendly way (one A4 page in PDF):
  - academic and professional background,
  - experiences (work, volunteer work, projects),
  - technical skills,
  - languages,
  - and personal projects.

Everything (dev environment, content, build and deployment) goes through [Nix](https://nixos.org/) flakes.

### Layout

| Path | Role |
| --- | --- |
| `flake.nix` | Dev shell, package and NixOS module outputs |
| `nix/cv.nix` | The CV content, a [JSON Resume](https://jsonresume.org/schema/) attrset |
| `nix/package.nix` | Builds the static site for a given `cv` and `siteUrl` |
| `nix/module.nix` | NixOS module serving the site with nginx |

`cv.json` is generated from `nix/cv.nix` (by the dev shell and by the package), it is not versioned.

### Development

Enter the dev shell (Node.js, pnpm, tmux, lazygit), it also generates `cv.json`:
```bash
git clone https://github.com/EniumRaphael/portefolio
cd portefolio
nix develop
pnpm install
pnpm dev    # Watch mode to see changes
```

`tmux-setup` opens a ready-to-use tmux session (editor, dev server, git).

### Change the content

Edit `nix/cv.nix`, then re-enter `nix develop` to regenerate `cv.json`.

Available themes (`basics.theme`):
  - default
  - blue
  - cyber
  - green
  - red
  - Catppuccin Mocha (`mocha`)
  - TokyoNight (`tokyonight`)

### Build

```bash
nix build   # The site is in ./result
```

The canonical URL (canonical, `og:url`, JSON-LD) is passed to the build as `SITE_URL`.

### Deploy with the NixOS module

One build and one canonical URL per domain:
```nix
{
  inputs.portefolio.url = "github:EniumRaphael/portefolio";
  # ...
  imports = [ inputs.portefolio.nixosModules.default ];
  services.portefolio = {
    enable = true;
    domains = [ "example.net" "example.com" ];
    # cv = { ... };  # optional, defaults to nix/cv.nix
  };
}
```

Other options: `user`, `group`, `createUser`, `forceSSL` and `enableACME` (all enabled by default except the user/group names).

Based on [Smilesharks/dev-portfolio](https://github.com/Smilesharks/dev-portfolio), with customizations for my own portfolio.
