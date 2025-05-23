{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python311;

        ipythonIcat = python.pkgs.buildPythonPackage {
          pname = "ipython-icat";
          version = "0.3.0";

          format = "wheel";

          src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/py3/i/ipython-icat/ipython_icat-0.3.0-py3-none-any.whl";
            sha256 = "sha256-heGtVZDWCFkTzKKnfcmlcovGiHOSr2yWN3YON7INW5c=";
          };

          propagatedBuildInputs = with python.pkgs; [
            ipython
            pillow
          ];

          doCheck = false;
        };

        pythonEnv = python.withPackages (ps: with ps; [
          ipython
          pip
          matplotlib
          ipythonIcat
        ]);

        extraLibs = [
          pkgs.uv
          pkgs.zlib
          #pkgs.python311Packages.cython
          #pkgs.python311Packages.debugpy
          #pkgs.python311Packages.setuptools
          #pkgs.texlivePackages.cm  # Computer Modern fonts
          #pkgs.texlivePackages.cm-super
          #pkgs.texlive.combined.scheme-full
        ];
      in {
        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv ] ++ extraLibs;
          shellHook = ''
            export LD_LIBRARY_PATH="${
              pkgs.lib.makeLibraryPath (extraLibs ++ [ pkgs.stdenv.cc.cc ])
            }:$LD_LIBRARY_PATH"
          '';
        };
      });
}

