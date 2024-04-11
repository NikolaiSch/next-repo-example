{
  description = "My flake with dream2nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  

  outputs =
    inputs@{
      self,
      dream2nix,
      nixpkgs,
      nixos-generators,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      package = dream2nix.lib.evalModules {
        packageSets.nixpkgs = inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
          }
        ];
      };
      shellScript = pkgs.writeShellApplication {
        name = "start-next";

        runtimeInputs = [ pkgs.nodejs ];

        text = ''
          cd ~/.nix-profile/lib/node_modules/my-next-app
          ${pkgs.nodejs}/bin/npm run start
        '';
      };
    in

    {
      packages.${system} = {
        default = package;
        start-next = shellScript;
        azure = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "azure";
        };
      };

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { pkgs, ... }:
            {
              systemd.services.run-next = {
                description = "run my nextjs project";
                after = [ "network.target" ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  ExecStart = shellScript;
                  Restart = "always";
                };
              };
            }
          )
        ];
      };
    };
}
