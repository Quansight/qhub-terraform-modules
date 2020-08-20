let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/32a89684d8cd9fa823b1e2c7def64786f41a4f05.tar.gz";
    sha256 = "1mhkv1i6mzs0yw0f5kxcr4mbsdbsn2p466wnhd2n48b2n6cwl94v";
  }) { };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.terraform_0_13
    pkgs.minikube
    pkgs.kubectl
    pkgs.k9s
  ];
}
