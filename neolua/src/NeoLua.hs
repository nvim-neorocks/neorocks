{-# LANGUAGE LambdaCase #-}

module NeoLua where

import Control.Monad (when)
import LuaOptions
import System.Exit (ExitCode (..), exitWith)
import System.Process (spawnProcess, waitForProcess)

main :: IO ()
main = do
  luaOptions <- getLuaOptions
  let nvimOptions = toNvimOptions luaOptions
  when (showVersionInfo luaOptions) showNvimVersion
  spawnProcess "nvim" ("-Es" : nvimOptions)
    >>= waitForProcess
    >>= exitWith

showNvimVersion :: IO ()
showNvimVersion =
  spawnProcess "nvim" ["--version"]
    >>= waitForProcess
    >>= \case
      err@(ExitFailure _) -> exitWith err
      _ -> pure ()
