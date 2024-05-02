{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  mpi4py,
  mpi,
  pytest,
}:

buildPythonPackage {
  pname = "pytest-mpi";
  version = "2023.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "pytest-mpi";
    rev = "8241bdc453da753e783f9a9bf8cde56787e10a40";
    hash = "sha256-aAPJWCtfpDqV6oowkAD/VPVIqXea6paDK+uCxjdSNoI=";
  };

  build-system = [ hatchling ];

  dependencies = [
    (mpi4py.override { inherit mpi; })
    pytest
  ];
}
