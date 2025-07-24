{
  fetchFromGitHub,
  lib,
  python3Packages,
  gnupg,
  perl,
}:

let
  version = "3.0.0";
in
python3Packages.buildPythonApplication {
  pname = "pius";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jaymzh";
    repo = "pius";
    rev = "v${version}";
    sha256 = "0l87dx7n6iwy8alxnhvval8h1kl4da6a59hsilbi65c6bpj4dh3y";
  };

  patchPhase = ''
    substituteInPlace pius-keyring-mgr \
      --replace-fail '/usr/bin/gpg' '${gnupg}/bin/gpg'

    substituteInPlace libpius/constants.py \
      --replace-fail '/usr/bin/gpg2' '${gnupg}/bin/gpg'
  '';

  build-system = with python3Packages; [ setuptools ];

  buildInputs = [ perl ];

  meta = {
    homepage = "https://www.phildev.net/pius/";

    description = "PGP Individual UID Signer (PIUS), quickly and easily sign UIDs on a set of PGP keys";

    longDescription = ''
      This software will allow you to quickly and easily sign each UID on
      a set of PGP keys.  It is designed to take the pain out of the
      sign-all-the-keys part of PGP Keysigning Party while adding security
      to the process.
    '';

    license = lib.licenses.gpl2Only;

    platforms = lib.platforms.gnu ++ lib.platforms.linux;
    maintainers = with lib.maintainers; [ ];
  };
}
