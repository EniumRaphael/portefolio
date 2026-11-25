# NixOS module: serves the portfolio on one or more domain names.
# `mkSite` is injected by the flake (see flake.nix).
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
    enable = lib.mkEnableOption "the portfolio (static site served by nginx)";

    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [
        "example.net"
        "example.com"
      ];
      description = ''
        Domain names to serve. Each domain has its own build, with its
        own canonical URL (canonical, og:url, JSON-LD).
      '';
    };

    cv = lib.mkOption {
      type = lib.types.attrs;
      default = import ./cv.nix;
      defaultText = lib.literalExpression "import ./cv.nix";
      description = "CV data (JSON Resume schema), replaces cv.json.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "portefolio";
      description = ''
        User the nginx workers run as to serve the site.
        Warning: nginx is shared, so this also affects the other vhosts.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "portefolio";
      description = "Group associated with `user`.";
    };

    createUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Create the system user and group (disable if they already exist).";
    };

    forceSSL = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Redirect HTTP to HTTPS.";
    };

    enableACME = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatic Let's Encrypt certificates for each domain.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.domains != [ ];
        message = "services.portefolio.domains must not be empty.";
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
