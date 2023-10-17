{ lib, stdenv, fetchurl, installShellFiles, testers, dagger }:

stdenv.mkDerivation rec {
  pname = "dagger";
  version = "0.8.8";

  src =
    let
      inherit (stdenv.hostPlatform) system;

      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");

      suffix = selectSystem {
        x86_64-linux = "linux_amd64";
        x86_64-darwin = "darwin_amd64";
        aarch64-linux = "linux_arm64";
        aarch64-darwin = "darwin_arm64";
      };
      hash = selectSystem {
        x86_64-linux = "sha256-q/QO1WGbdB3S1e4Sv8/vDkHdSoJa187gnkawBwbniZM=";
        x86_64-darwin = "sha256-klRgcToFKnfNod2BIbs9x7c/Keg70r+D8N4Xvg7uFZk=";
        aarch64-linux = "sha256-juVqvLWdP2WGPr2q+tHaMjgdM7yEAGErzbE6+ci4128=";
        aarch64-darwin = "sha256-YmcPnhqZlNr+7kjFXqRRSbRPFWxVZCd8rs6mKZCw4KY=";
      };
    in
    fetchurl {
      inherit hash;

      url = "https://github.com/dagger/dagger/releases/download/v${version}/dagger_v${version}_${suffix}.tar.gz";
    };

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp dagger $out/bin/

    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dagger \
      --bash <($out/bin/dagger completion bash) \
      --fish <($out/bin/dagger completion fish) \
      --zsh <($out/bin/dagger completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = dagger;
    command = "dagger run";
    version = "v${version}";
  };

  meta = with lib; {
    description = "A portable devkit for CICD pipelines";
    homepage = "https://dagger.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ sagikazarmark ];
  };
}