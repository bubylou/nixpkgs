{
  xdotool,
  rustPlatform,
  runCommand,
  pkg-config,
  python3,
  openssl,
  ninja,
  linkFarm,
  libayatana-appindicator,
  lib,
  harfbuzz,
  gn,
  glib,
  gtk3,
  fontconfig,
  freetype,
  fetchgit,
  fetchFromGitHub,
  curl,
  cmake,
  clangStdenv,
}:
rustPlatform.buildRustPackage.override {stdenv = clangStdenv;} (finalAttrs: {
  pname = "vykar";
  version = "v0.12.12";

  src = fetchFromGitHub {
    owner = "borgbase";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-gmSmMqC9FFo/PakeKOv6d77mapePejN6iF7Zg1/KPB4=";
  };

  cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";

  buildInputs = [
    curl
    freetype
    glib
    gtk3
    libayatana-appindicator
    openssl
    xdotool
  ];

  nativeBuildInputs = [
    cmake
    fontconfig
    pkg-config
    python3
    rustPlatform.bindgenHook
  ];

  env = rec {
    SKIA_SOURCE_DIR = let
      repo = fetchFromGitHub {
        owner = "rust-skia";
        repo = "rust-skia";
        # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
        tag = "0.90.0";
        hash = "sha256-eX65UGr+HopRFRJAw1Qa8oi2k7LME9WvDz0/9kOBO0k=";
      };
      # The externals for skia are taken from skia/DEPS
      externals = linkFarm "skia-externals" (
        lib.mapAttrsToList (name: value: {
          inherit name;
          path = fetchgit value;
        }) (lib.importJSON ./skia-externals.json)
      );
    in
      runCommand "source" {} ''
        mkdir -p $out/third_party/externals
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';

    SKIA_GN_COMMAND = lib.getExe gn;
    SKIA_NINJA_COMMAND = lib.getExe ninja;
    SKIA_USE_FREETYPE = "1";
    SKIA_USE_SYSTEM_LIBRARIES = "1";
    NIX_CFLAGS_COMPILE = "-I${lib.getDev harfbuzz}/include/harfbuzz";
  };

  meta = {
    description = "Fast, encrypted, deduplicated backups in Rust.";
    longDescription = ''
      Fast, encrypted, deduplicated backups in Rust,
      with friendly YAML config, a desktop GUI, and support for
      S3, custom REST and SFTP storage.
    '';
    homepage = "https://github.com/borgbase/vykar";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [bubylou];
  };
})
