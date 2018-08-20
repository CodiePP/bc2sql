{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, aeson, base, bytestring, SHA, stdenv, unix
      , wreq, zlib, microlens, postgresql-simple, postgresql
      , libiconv
      }:
      mkDerivation {
        pname = "bc2sql";
        version = "0.1.0.0";
        sha256 = "0";
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [ aeson base bytestring SHA unix wreq microlens postgresql-simple ];
        executableHaskellDepends = [ aeson base bytestring SHA unix wreq microlens postgresql-simple ];
	libraryPkgconfigDepends = [ libiconv zlib postgresql ];
        homepage = "https://github.com/CodiePP/bc2sql";
        description = "map Ada explorer information to sql";
        license = stdenv.lib.licenses.mit;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
