{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.numa;
in
{
  options.services.numa = {
    enable = lib.mkEnableOption "enable numa service";
    package = lib.mkPackageOption pkgs "numa" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = "numa";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "numa";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.numa = {
      description = "Numa DNS — DNS you own, everywhere you go";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${cfg.package}/bin/numa" ];
        Restart = "always";
        RestartSec = 2;

        User = cfg.user;
        Group = cfg.group;
        DynamicUser = true;

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";

        StateDirectory = "numa";
        StateDirectoryMode = "0750";
        ConfigurationDirectory = "numa";
        ConfigurationDirectoryMode = "0755";

        NoNewPrivileges = true;
        ProtectSystem = "strict";

        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";

        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "numa";
      };
    };

    users.users = lib.mkIf (cfg.user == "numa") {
      numa = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "numa") {
      numa = { };
    };
  };
}
