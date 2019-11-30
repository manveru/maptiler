{ lib, crystal, writeTextDir, runCommandNoCC }:
let
  inherit (lib) fileContents any;

  shard2json = crystal.buildCrystalPackage {
    name = "parse-shard-version";
    version = "0.0.1";
    src = writeTextDir "src/parse.cr" ''
      require "yaml"
      require "json"

      puts YAML.parse(File.read(ARGV[0])).to_json
    '';

    crystalBinaries.parse.src = "src/parse.cr";
  };

  shardJson = path:
    runCommandNoCC "shard.json" { buildInputs = [ shard2json ]; } ''
      parse ${path} > $out
    '';

  # NOTE: find a way to handle duplicates better, atm they may override each
  # other without warning
  mkWhiteList = allowedPaths:
    lib.foldl' (sum: allowed:
      if (lib.pathIsDirectory allowed) then {
        tree = lib.recursiveUpdate sum.tree
          (lib.setAttrByPath (pathToParts allowed) true);
        prefixes = sum.prefixes ++ [ (toString allowed) ];
      } else {
        tree = lib.recursiveUpdate sum.tree
          (lib.setAttrByPath (pathToParts allowed) false);
        prefixes = sum.prefixes;
      }) {
        tree = { };
        prefixes = [ ];
      } allowedPaths;

  pathToParts = path: (__tail (lib.splitString "/" (toString path)));

  isWhiteListed = patterns: name: type:
    let
      parts = pathToParts name;
      matchesTree = lib.hasAttrByPath parts patterns.tree;
      matchesPrefix = any (pre: lib.hasPrefix pre name) patterns.prefixes;
    in matchesTree || matchesPrefix;

  whiteList = root: allowedPaths:
    let
      patterns = mkWhiteList allowedPaths;
      filter = isWhiteListed patterns;
    in __filterSource filter root;
in {
  inherit shardJson whiteList;
  shard = __fromJSON (fileContents ( shardJson ../shard.yml ));
  pp = v: __trace (__toJSON v) v;
}
