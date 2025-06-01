{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  wheel,
  alembic,
  bleach,
  boto3,
  celery,
  click,
  ffmpeg-python,
  flask,
  flask-caching,
  flask-compress,
  flask-cors,
  flask-jwt-extended,
  flask-limiter,
  flask-sqlalchemy,
  gramps,
  gramps-ql,
  jsonschema,
  marshmallow,
  object-ql,
  orjson,
  pdf2image,
  pillow,
  pygobject3,
  pytesseract,
  sifts,
  sqlalchemy,
  unidecode,
  waitress,
  webargs,
  accelerate,
  openai,
  sentence-transformers,
  pytestCheckHook,
  pyyaml,
  gobject-introspection,
  gtk3,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "gramps-web-api";
  version = "3.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps-web-api";
    rev = "v${version}";
    hash = "sha256-BI90Xh6tp9uaIAbeO4LX/LaWmSh/aBdYnzjwu5J1/0k=";
  };

  patches = [
    # fixes TestMediaArchiv::test_create_archive which tries to use an example
    # zip file from the nix store (which has non-zip compatible timestamps)
    ./remove-zip-timestamp-strictness.patch
    ./instance-path.patch
  ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  pythonRelaxDeps = [ "boto3" ];

  dependencies = [
    alembic
    bleach
    boto3
    celery
    click
    ffmpeg-python
    flask
    flask-caching
    flask-compress
    flask-cors
    flask-jwt-extended
    flask-limiter
    flask-sqlalchemy
    gramps
    gramps-ql
    jsonschema
    marshmallow
    object-ql
    orjson
    pdf2image
    pillow
    pygobject3
    pytesseract
    sifts
    sqlalchemy
    unidecode
    waitress
    webargs

    accelerate
    openai
    sentence-transformers

  ] ++ bleach.optional-dependencies.css;

  nativeBuildInputs = [
    gobject-introspection
    gtk3
    wrapGAppsHook3
  ];

  optional-dependencies = {
    ai = [
      accelerate
      openai
      sentence-transformers
    ];
  };

  doCheck = false;

  preCheck = ''
    # don't try to download a semantic search model from the internet
    substituteInPlace "tests/test_endpoints/__init__.py" \
      --replace-fail '"paraphrase-albert-small-v2"' '""'
  '';

  disabledTestPaths = [
    # mock_s3 is not found in moto 5.0.0+
    "tests/test_s3.py"
    "tests/test_endpoints/test_s3.py"

    # Requires a semantic search model be present
    "tests/test_endpoints/test_chat.py"
  ];

  disabledTests = [
    # network access needed
    "test_get_faces"
    "test_get_faces_requires_token"

    # the test wants to load some fonts
    "test_get_ocr"

    # pytest-celery is not packaged in nixpkgs
    "test_task_noauth"
    "test_task_nonexistant"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    writableTmpDirAsHomeHook
  ];

  pythonImportsCheck = [
    "gramps_webapi"
  ];

  meta = {
    description = "A RESTful web API for Gramps - backend of Gramps Web";
    homepage = "https://github.com/gramps-project/gramps-web-api";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
