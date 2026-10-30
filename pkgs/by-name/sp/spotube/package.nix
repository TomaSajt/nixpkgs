{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk21,
  cargo,
  writeText,
  rustPlatform,
}:

let
  gradle = gradle_9;
  jdk = jdk21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "spotube";
  version = "6.0.0-beta.0";

  src = fetchFromGitHub {
    owner = "team-spotube";
    repo = "spotube";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nR2/R6Aa87Y1Mz66iKcOFbeEvYoDO0LU0I6sXw7KpPY=";
  };

  patches = [ ./a.patch ];

  postPatch = ''
    substituteInPlace settings.gradle.kts \
      --replace-fail 'include(":js_plugin_example")' ""
  '';

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  cargoRoot = "composeApp";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;
    hash = "sha256-U93ECB9G/qi8h8YQcEV/wSEWOwG+72/TVGcQ8ydcgEE=";
  };

  nativeBuildInputs = [
    gradle
    jdk
    cargo
    rustPlatform.cargoSetupHook
  ];

  # must not be named "gradleInitScript"
  gradleInitScriptV2 = writeText "init-script.gradle.kts" ''

    /*
    gradle.projectsLoaded {
      rootProject.allprojects {
        task nixDownloadDepsV2 {
          notCompatibleWithConfigurationCache("idk")
          doLast {
            project.configurations.findAll { it.canBeResolved }.each { it.resolve() }
            project.buildscript.configurations.findAll { it.canBeResolved }.each { it.resolve() }
          }
        }
      }
    }
    */

    /*
    import org.gradle.api.artifacts.VersionCatalogsExtension
    gradle.rootProject {
      tasks.register("fetchAll") {
        doLast {
          val catalog = extensions
            .getByType<VersionCatalogsExtension>()
            .named("libs")

          catalog.libraryAliases.forEach {
            println("$it: ''${catalog.findLibrary(it).get().get()}")
          }

          catalog.versionAliases.forEach {
            println("$it: ''${catalog.findVersion(it).get().get().requiredVersion}")
          }

          catalog.pluginAliases.forEach {
            println("$it: ''${catalog.findPlugin(it).get().get()}")
          }
        }
      }
    }
    */




    import org.gradle.api.artifacts.VersionCatalogsExtension

    gradle.allprojects {
        val project = this

        project.tasks.register("resolveVersionCatalog") {
            group = "help"
            description = "Resolves all dependencies from the version catalog."

            doLast {
                val catalogs = project.extensions
                    .getByType<VersionCatalogsExtension>()

                val libs = catalogs.named("libs")

                val configuration = project.configurations.maybeCreate(
                    "resolveVersionCatalog"
                ).apply {
                    isCanBeResolved = true
                    isCanBeConsumed = false
                }

                libs.libraryAliases.forEach { alias ->
                    configuration.dependencies.add(
                        libs.findLibrary(alias).get().get()
                    )
                }

                configuration.resolve()
            }
        }
    }

  '';

  gradleUpdateScript = ''
    runHook preBuild
    runHook preGradleUpdate

    #gradle --init-script "$gradleInitScriptV2" :nixDownloadDepsV2
    gradle --init-script "$gradleInitScriptV2" resolveVersionCatalog
    #gradle tasks

    runHook postGradleUpdate
  '';

  #gradleBuildTask = ":composeApp:run";
  gradleBuildTask = ":composeApp:createGraalvmNativeDistributable";

  meta = {
    description = "Open source music streaming app for both desktop and mobile";
    downloadPage = "https://github.com/team-spotube/spotube/releases";
    homepage = "https://spotube.cc/";
    license = lib.licenses.agpl3Plus;
    mainProgram = "spotube";
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
