{}:
# TODO: Add flake.nix test inputs as arguments here
final: prev:
with final.lib;
with final.stdenv; let
  mkTest = {name}:
    mkDerivation {
      inherit name;

      phases = [
        "buildPhase"
        "checkPhase"
      ];

      doCheck = true;

      buildInputs = with final; [
      ];

      buildPhase = ''
        mkdir -p $out
        true
      '';

      checkPhase = ''
        true
      '';
    };
in {
  ci = mkTest {name = "ci";};
}
