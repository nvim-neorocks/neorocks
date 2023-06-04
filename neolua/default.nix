{ mkDerivation, base, lib, optparse-applicative, process, text }:
mkDerivation {
  pname = "neolua";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base optparse-applicative process text
  ];
  homepage = "https://github.com/nvim-neorocks/neorocks#readme";
  description = "A CLI adapter to map Lua's CLI to Neovim's CLI for lua interpretation";
  license = lib.licenses.gpl2Only;
  mainProgram = "neolua";
}
