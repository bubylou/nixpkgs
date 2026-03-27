{
  pkg-config,
  llvmPackages,
  git,
  cmake,
  sqlite,
  ncurses,
  openssl,
  libpq,
  libiconv,
  rustPlatform,
  lib,
  fetchFromGitHub,
}: let
  owner = "dan-online";
  pname = "autopulse";
  version = "v1.6.0";
  hash = "sha256-Fmp8MyXCeeDbusfZiCUauZGveZ2AdCX6Z6WBAldh3Ro=";
in
  rustPlatform.buildRustPackage (finalAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      repo = finalAttrs.pname;
      tag = finalAttrs.version;
      inherit owner hash;
    };

    nativeBuildInputs = [
      pkg-config
      llvmPackages.clang
      llvmPackages.libclang
      git
      cmake
    ];

    buildInputs = [
      sqlite
      ncurses
      openssl
      libpq
      libiconv
    ];

    buildFeatures = [
      "postgres"
      "sqlite"
    ];

    cargoHash = "sha256-4gFQFftHVnYzBvQD5OjcO7kNKQA+nrmj2+VQBM2G2RU=";

    meta = {
      description = "service that updates media servers";
      longDescription = ''        💫 automated lightweight service that
                updates media servers like Plex and Jellyfin based on notifications
                from media organizers like Sonarr and Radarr
      '';
      homepage = "https://github.com/dan-online/autopulse";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [bubylou];
    };
  })
