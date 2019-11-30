{ pkgs ? import ./nix {}
, crystal ? pkgs.crystal
, whiteList ? pkgs.packages.whiteList
, shard ? pkgs.packages.shard }:

crystal.buildCrystalPackage {
  inherit (shard) name version;

  src = whiteList ./. [ ./src ];
  shardsFile = ./shards.nix;

  buildInputs = with pkgs; [ readline ];

  crystalBinaries.maptiler.src = "src/cli.cr";
}
