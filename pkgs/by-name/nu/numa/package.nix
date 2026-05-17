{
  rustPlatform,
  nix-update-script,
  lib,
  fetchFromGitHub,
}:
let
  pname = "numa";
  version = "0.18.0";
  gitHash = "sha256-EvG2gq9uXJxwBUMGVV9w7J2v3jWPO5mzuGo6wZOz7l8";
  cargoHash = "sha256-0qVQHlP8CrtnAoujztJo+1HaUj7Hhg1EPEHNwyKtO0o=";

  src = fetchFromGitHub {
    owner = "razvandimescu";
    repo = pname;
    rev = "v${version}";
    hash = gitHash;
  };
in
rustPlatform.buildRustPackage {
  inherit
    pname
    src
    version
    cargoHash
    ;

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Portable DNS resolver in Rust";
    homepage = "https://numa.rs";
    changelog = "https://github.com/razvandimescu/numa/releases/tag/v${version}";
    license = with lib.licenses; mit;
    maintainers = with lib.maintainers; [ bubylou ];
    mainProgram = "numa";
  };
}
