{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home-lab.autopulse;
in {
  options = {
    home-lab.autopulse = {
      enable = lib.mkEnableOption "Autopulse, automated lightweight service that updates media servers";

      package = lib.mkPackageOption pkgs "autopulse" {};

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports in the firewall for the Unpackerr web interface.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "autopulse";
        description = "User account under which Unpackerr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "autopulse";
        description = "Group under which Unpackerr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-autopulse".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.autopulse = {
      description = "Unpackerr";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/autopulse";
        Restart = "on-failure";
        RestartSec = "10";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [2875];
    };

    users.users = lib.mkIf (cfg.user == "autopulse") {
      autopulse = {
        inherit (cfg) group;
        home = cfg.dataDir;
        uid = config.ids.uids.autopulse;
      };
    };

    users.groups = lib.mkIf (cfg.group == "autopulse") {
      autopulse.gid = config.ids.gids.autopulse;
    };
  };
}
