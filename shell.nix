with { pkgs = import ./nix { }; };
pkgs.mkShell { buildInputs = with pkgs; [ niv crystal shards crystal2nix readline ]; }
