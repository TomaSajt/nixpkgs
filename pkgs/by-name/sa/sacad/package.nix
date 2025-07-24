{
  lib,
  python3Packages,
  fetchPypi,
  jpegoptim,
  optipng,
}:

python3Packages.buildPythonApplication rec {
  pname = "sacad";
  version = "2.8.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/NyRnQSqDZv+LJ1bPO35T9icQ2PN9Oa+nSmrLkQimnQ=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aiohttp
    appdirs
    bitarray
    cssselect
    fake-useragent
    lxml
    mutagen
    pillow
    tqdm
    unidecode
    web-cache
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        jpegoptim
        optipng
      ]
    }"
  ];

  # tests require internet connection
  doCheck = false;

  pythonImportsCheck = [ "sacad" ];

  meta = with lib; {
    description = "Smart Automatic Cover Art Downloader";
    homepage = "https://github.com/desbma/sacad";
    license = licenses.mpl20;
    maintainers = with maintainers; [ moni ];
  };
}
