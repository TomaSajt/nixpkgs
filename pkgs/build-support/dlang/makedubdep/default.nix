{ fetchzip }:

{ pname, version, ... }@attrs:
{
  inherit pname version;
  src = fetchzip (
    {
      name = "dub-${pname}-${version}";
      url = "mirror://dub/${pname}/${version}.zip";
    }
    // builtins.removeAttrs attrs [
      "pname"
      "version"
    ]
  );
}
