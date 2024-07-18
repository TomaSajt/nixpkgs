let
  # This is in the outer scope to ensure that it gets put into the import-value cache of Nix
  generated = builtins.fromJSON (builtins.readFile ./bioc-annotation-packages.json);
in
{ self, derive }:
let
  derive2 = derive { biocVersion = "3.19"; };
in
builtins.mapAttrs (
  k: v: derive2 (v // { depends = builtins.map (name: self.${name}) v.depends; })
) generated
