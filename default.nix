{ config, dream2nix, ... }:
{

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = ./my-next-app;
  };

  deps =
    { nixpkgs, ... }:
    {
      inherit (nixpkgs) stdenv nodejs;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "my-next-app";
  version = "0.1.1";
}
