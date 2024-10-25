{ lib, buildGoModule, fetchFromGitHub, installShellFiles, testers }:

buildGoModule rec {
  pname = "spacectl";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "spacelift-io";
    repo = "spacectl";
    rev = "v${version}";
    hash = "sha256-pO+jYuCyP6YrU9vE3//O0EyTDXYQ1WSpFI/8WbneDCA=";
  };

  vendorHash = "sha256-SYfXG6YM0Q2rCnoTM2tYvE17uBCD8yQiW/5DTCxMPWo=";

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/spacectl completion $shell > spacectl.$shell
      installShellCompletion spacectl.$shell
    done
  '';

  meta = with lib; {
    description = "Spacelift client and CLI";
    mainProgram = "spacectl";
    homepage = "https://docs.spacelift.io/concepts/spacectl";
    license = licenses.mit;
    maintainers = with maintainers; [
      bubylou
    ];
  };
}
