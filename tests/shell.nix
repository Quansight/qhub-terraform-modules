{ pkgs ? import <nixpkgs> { } }:

let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c4b26e702044dbf40f8236136c099d8ab6778514.tar.gz";
    sha256 = "0w6hgs01qzni3a7cvgadjlmcdlb6vay3w910vh4k9fc949ii7s60";
  }) { };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.terraform_0_13
    pkgs.minikube
    pkgs.docker-machine
    pkgs.docker-machine-kvm2
    pkgs.kubectl
    pkgs.k9s
  ];
}
