{ stdenv, fetchFromGitHub, pkgs, makeWrapper, pname, version, src }:

let
  pypkgs = python-packages: with python-packages; [
    pyserial
    click
    cryptography
    future
    pyparsing
    pyelftools
    setuptools
  ];
  python = pkgs.python2.withPackages pypkgs;

in stdenv.mkDerivation rec {
  inherit pname version src;

  buildInputs = [
    python
  ];

  propagatedBuildInputs = with pkgs; [
    cmake
    ninja
    gcc
    git
    ncurses
    flex
    bison
    gperf
    ccache
  ] ++ [
    python
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    cp -r . $out
  '';

  meta = with stdenv.lib; {
    description = "ESP IDF";
    homepage = https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html;
    license = licenses.gpl3;
  };
}