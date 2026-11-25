# Module NixOS : sert le portfolio sur un ou plusieurs noms de domaine.
# `mkSite` est injecté par le flake (voir flake.nix).
{ mkSite }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.portefolio;
in
{
  options.services.portefolio = {
    enable = lib.mkEnableOption "le portfolio (site statique servi par nginx)";

    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [
        "example.net"
        "example.com"
      ];
      description = ''
        Noms de domaine servis. Chaque domaine a son propre build, avec
        sa propre URL canonique (canonical, og:url, JSON-LD).
      '';
    };

    cv = lib.mkOption {
      type = lib.types.attrs;
      default = import ./cv.nix;
      defaultText = lib.literalExpression "import ./cv.nix";
      description = "Données du CV (schéma JSON Resume), remplace cv.json.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "portefolio";
      description = ''
        Utilisateur sous lequel nginx (workers) sert le site.
        Attention : nginx est partagé, cela concerne aussi les autres vhosts.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "portefolio";
      description = "Groupe associé à `user`.";
    };

    createUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Crée l'utilisateur et le groupe système (désactiver s'ils existent déjà).";
    };

    forceSSL = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Redirige HTTP vers HTTPS.";
    };

    enableACME = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Certificats Let's Encrypt automatiques pour chaque domaine.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.domains != [ ];
        message = "services.portefolio.domains ne doit pas être vide.";
      }
    ];

    users.users = lib.mkIf cfg.createUser {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "Portefolio web server";
      };
    };
    users.groups = lib.mkIf cfg.createUser {
      ${cfg.group} = { };
    };

    services.nginx = {
      enable = true;
      user = lib.mkDefault cfg.user;
      group = lib.mkDefault cfg.group;
      virtualHosts = lib.genAttrs cfg.domains (domain: {
        inherit (cfg) forceSSL enableACME;
        root = mkSite pkgs {
          inherit (cfg) cv;
          siteUrl = "https://${domain}";
        };
        locations."/".extraConfig = ''
          try_files $uri $uri/index.html =404;
        '';
      });
    };
  };
}
