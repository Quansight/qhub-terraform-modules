{ pkgs ? import <nixpkgs> { } }:

let
  newerPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/6449c5eee5ef929a8a2f1ac30699a50907e1a2ed.tar.gz";
    sha256 = "0h4cjghqlp44lyrdzv80bdi7vvi6j9na3cjaqs9jvb9p0rsn6026";
  }) { };
in
pkgs.mkShell {
  buildInputs = [
    newerPkgs.terraform_0_13
    pkgs.minikube
    pkgs.kubectl
    pkgs.k9s
  ];
}
