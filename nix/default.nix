{ sources ? import ./sources.nix }:
with
  { overlay = self: super:
      { inherit (import sources.niv {}) niv;
        packages = self.callPackages ./packages.nix {};
        crystal = (import ~/github/nixos/nixpkgs {}).crystal_0_32;
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
