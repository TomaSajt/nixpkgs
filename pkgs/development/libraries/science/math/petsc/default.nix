{
  lib,
  stdenv,
  callPackage,
  fetchFromGitLab,
  fetchurl,
  darwin,
  gfortran,
  python3,
  blas,
  lapack,
  petsc-optimized ? false,
  petsc-scalar-type ? "real",
  petsc-precision ? "double",
  with64BitIndices ? false,
  mpiSupport ? true,
  mpi, # generic mpi dependency
  openssh, # required for openmpi tests
  withP4est ? false,
  p4est,
  zlib, # propagated by p4est but required by petsc
  withHdf5 ? false,
  hdf5-mpi,
  withPtscotch ? false,
  scotch,
  withSuperlu ? false,
  superlu,
  withHypre ? false,
  hypre,
  withScalapack ? false,
  scalapack,
  withMumps ? false,
  withChaco ? false,
  buildEnv,
}:

# This version of PETSc does not support a non-MPI p4est build
assert withP4est -> p4est.mpiSupport;
assert withMumps -> withScalapack;
assert withChaco -> !with64BitIndices; # chaco is 32 bit only
assert withSuperlu -> !with64BitIndices; # SuperLU is 32 bit only

let
  blaslapack = buildEnv {
    name = "blaslapack-${blas.version}+${lapack.version}";
    paths = [
      (lib.getLib blas)
      (lib.getDev blas)
      (lib.getLib lapack)
      (lib.getDev lapack)
    ];
  };

  withLibrary =
    name: pkg: enable:
    let
      combinedPkg = buildEnv {
        name = "${pkg.name}-combined";
        paths = [
          (lib.getLib pkg)
          (lib.getDev pkg)
        ];
      };
    in
    ''
      "--with-${name}=${if enable then "1" else "0"}"
      ${lib.optionalString enable ''
        "--with-${name}-dir=${combinedPkg}"
      ''}
    '';

  chaco-src = fetchurl {
    url = "https://bitbucket.org/petsc/pkg-chaco/get/v2.2-p4.tar.gz";
    hash = "sha256-UWAsyc5zI++On6ThPqPUNpiHtzPEtcyIDyJ/65aXHP0=";
  };
  mumps-src = fetchurl {
    url = "https://graal.ens-lyon.fr/MUMPS/MUMPS_5.6.2.tar.gz";
    hash = "sha256-E6LBr/K9Gqkv6Et7NdiPQ0NAGZY8oJ736MkIIajx1Zo=";
  };
  sowing = callPackage ./sowing.nix { };
  hdf5 = (hdf5-mpi.override { inherit mpi; });
  scotch' =
    (scotch.override {
      inherit mpi;
      withIntSize64 = with64BitIndices;
    }).overrideAttrs
      (attrs: {
        buildFlags = [ "ptesmumps esmumps" ];
      });

  scalapack' = scalapack.override { inherit mpi; };
  hypre' = hypre.override {
    inherit mpi;
    enableShared = false;
    enableBigInt = with64BitIndices;
    enableComplex = petsc-scalar-type == "complex";
  };

  p4est' = p4est.override (prev: {
    p4est-sc = prev.p4est-sc.override { inherit mpi; };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "petsc";
  version = "3.21.1";

  src = fetchFromGitLab {
    owner = "petsc";
    repo = "petsc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Td9Avc8ttQt3cRhmB7cCbQU+DaRjrOuVS8wybzzROhM=";
  };

  inherit mpiSupport;

  strictDeps = true;

  nativeBuildInputs = [
    python3
    gfortran
  ];

  buildInputs = lib.optionals withP4est [ p4est ]; # needed for propagation

  nativeCheckInputs = [ openssh ];

  # Both OpenMPI and MPICH get confused by the sandbox environment and spew errors like this (both to stdout and stderr):
  #     [hwloc/linux] failed to find sysfs cpu topology directory, aborting linux discovery.
  #     [1684747490.391106] [localhost:14258:0]       tcp_iface.c:837  UCX  ERROR scandir(/sys/class/net) failed: No such file or directory
  # These messages contaminate test output, which makes the quicktest suite to fail. The patch adds filtering for these messages.
  patches = [ ./filter_mpi_warnings.patch ];

  postPatch =
    lib.optionalString withChaco ''
      substituteInPlace config/BuildSystem/config/packages/Chaco.py \
          --replace-fail "'https://bitbucket.org/petsc/pkg-chaco/get/'+self.gitcommit+'.tar.gz'" "'file://${chaco-src}'";
    ''
    + lib.optionalString withMumps ''
      substituteInPlace config/BuildSystem/config/packages/MUMPS.py \
          --replace-fail "'https://graal.ens-lyon.fr/MUMPS/MUMPS_'+self.version+'.tar.gz'" "'file://${mumps-src}'" \
          --replace-fail "/bin/rm" "rm"
    ''
    + lib.optionalString stdenv.isDarwin ''
      substituteInPlace config/install.py \
        --replace-fail "/usr/bin/install_name_tool" "${darwin.cctools}/bin/install_name_tool"
    '';

  preConfigure = ''
    patchShebangs ./configure ./lib/petsc/bin
    configureFlagsArray+=(
      "--with-scalar-type=${petsc-scalar-type}"
      "--with-precision=${petsc-precision}"
      "--with-64-bit-indices=${if with64BitIndices then "1" else "0"}"

      ${withLibrary "blaslapack" blaslapack true}
      ${withLibrary "mpi" mpi mpiSupport}
      ${withLibrary "sowing" sowing true}
      ${withLibrary "hdf5" hdf5 withHdf5}
      ${withLibrary "scalapack" scalapack' withScalapack}
      ${withLibrary "ptscotch" scotch' withPtscotch}
      ${withLibrary "hypre" hypre' withHypre}
      ${withLibrary "superlu" superlu withSuperlu}

      ${withLibrary "zlib" zlib withP4est}
      ${withLibrary "p4est" p4est' withP4est}

      ${lib.optionalString withChaco ''
        "--download-chaco"
      ''}
      ${lib.optionalString withMumps ''
        "--download-mumps"
      ''}

      ${lib.optionalString petsc-optimized ''
        "--with-debugging=0"
        COPTFLAGS='-g -O3'
        FOPTFLAGS='-g -O3'
        CXXOPTFLAGS='-g -O3'
      ''}
    )
  '';
  /*
    configurePhase = ''
      runHook preConfigure
      ./configure "''${configureFlagsArray[@]}" || true
      cat configure.log
      runHook postConfigure
      '';
  */

  enableParallelBuilding = true;

  # only run tests after they have been placed into $out
  # workaround for `cannot find -lpetsc: No such file or directory`
  doCheck = false;
  doInstallCheck = stdenv.hostPlatform == stdenv.buildPlatform;
  installCheckTarget = "check";

  meta = {
    description = "Portable Extensible Toolkit for Scientific computation";
    homepage = "https://www.mcs.anl.gov/petsc/index.html";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [
      cburstedde
      tomasajt
    ];
  };
})
