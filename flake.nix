{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: {
    flake-utils.lib.eachDefaultSystem = (system: 
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
           defaultPackage.${system} = derivation {
              name = "next.js builder";
              system = system;
              builder = "${pkgs.bash}/bin/bash";
              args = [ ./builder.sh ];
              inherit pkgs;
            }; 
        }
    );
    

  };
}
