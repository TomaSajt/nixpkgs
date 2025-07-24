{
  lib,
  fetchFromGitHub,
  python3Packages,
  file,
  less,
  highlight,
  w3m,
  imagemagick,
  imagePreviewSupport ? true,
  sixelPreviewSupport ? true,
  neoVimSupport ? true,
  improvedEncodingDetection ? true,
  rightToLeftTextSupport ? false,
  unstableGitUpdater,
}:

python3Packages.buildPythonApplication {
  pname = "ranger";
  version = "1.9.3-unstable-2025-06-04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "7e38143eaa91c82bed8f309aa167b1e6f2607576";
    hash = "sha256-O0DjecncpN+Bv8Ng+keuvU9iVtWAV4a50p959pMvkww=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    lib.optionals imagePreviewSupport [ pillow ]
    ++ lib.optionals neoVimSupport [ pynvim ]
    ++ lib.optionals improvedEncodingDetection [ chardet ]
    ++ lib.optionals rightToLeftTextSupport [ python-bidi ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    astroid
    pylint
  ];

  makeWrapperArgs =
    let
      runtimeDeps = [
        less
        file
      ]
      ++ lib.optionals sixelPreviewSupport [ imagemagick ];
    in
    [
      "--prefix PATH : ${lib.makeBinPath runtimeDeps}"
    ];

  preConfigure = ''
    ${lib.optionalString (highlight != null) ''
      sed -i -e 's|^\s*highlight\b|${highlight}/bin/highlight|' \
        ranger/data/scope.sh
    ''}

    substituteInPlace ranger/__init__.py \
      --replace-fail "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"

    # give file previews out of the box
    substituteInPlace ranger/config/rc.conf \
      --replace-fail /usr/share $out/share \
      --replace-fail "#set preview_script ~/.config/ranger/scope.sh" "set preview_script $out/share/doc/ranger/config/scope.sh"
  ''
  + lib.optionalString imagePreviewSupport ''
    substituteInPlace ranger/ext/img_display.py \
      --replace-fail /usr/lib/w3m ${w3m}/libexec/w3m

    # give image previews out of the box when building with w3m
    substituteInPlace ranger/config/rc.conf \
      --replace-fail "set preview_images false" "set preview_images true"
  '';

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = {
    description = "File manager with minimalistic curses interface";
    homepage = "https://ranger.github.io/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      toonn
      lucasew
    ];
    mainProgram = "ranger";
  };
}
