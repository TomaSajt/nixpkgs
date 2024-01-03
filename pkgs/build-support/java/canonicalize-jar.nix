{ substituteAll, _7zz, zip }:

substituteAll {
  name = "canonicalize-jar";
  src = ./canonicalize-jar.sh;

  zz = "${_7zz}/bin/7zz";
  zip = "${zip}/bin/zip";
}
