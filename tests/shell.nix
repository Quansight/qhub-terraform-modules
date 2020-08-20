let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = [
    pkgs.terraform
    pkgs.minikube
    pkgs.kubectl
  ];
}