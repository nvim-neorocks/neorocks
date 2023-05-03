{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module LuaOptions
  ( ToNvimOptions (..)
  , LuaOptions
  , getLuaOptions
  , showVersionInfo
  ) where

import Data.Functor ((<&>))
import Data.Text (Text)
import qualified Data.Text as T
import Options.Applicative

class ToNvimOptions a where
  toNvimOptions :: a -> [String]

data LuaOptions = LuaOptions
  { optExec :: ExecOption
  , optRequireLibraries :: RequireOption
  , optShowVersionInfo :: Bool
  , optRunScript :: Maybe LuaScriptOption
  }
  deriving (Show, Eq)

instance ToNvimOptions LuaOptions where
  toNvimOptions LuaOptions{..} =
    toNvimOptions optRequireLibraries
      <> toNvimOptions optExec
      <> toNvimOptions optRunScript

newtype ExecOption = ExecOption
  { stats :: [Text]
  }
  deriving (Show, Eq)

instance ToNvimOptions ExecOption where
  toNvimOptions (ExecOption []) = []
  toNvimOptions ExecOption{..} =
    ["-c", "lua " <> unwords (T.unpack <$> stats)]

newtype RequireOption = RequireOption
  { modules :: [Text]
  }
  deriving (Show, Eq)

instance ToNvimOptions RequireOption where
  toNvimOptions (RequireOption []) = []
  toNvimOptions RequireOption{..} =
    ["-c", "lua " <> unwords (toNvimRequireModuleStr . T.unpack <$> modules)]
    where
      toNvimRequireModuleStr :: String -> String
      toNvimRequireModuleStr ('g' : '=' : modName) = "_G.require(\"" <> modName <> "\");"
      toNvimRequireModuleStr modName = "require(\"" <> modName <> "\");"

data LuaScriptOption = LuaScriptOption
  { script :: FilePath
  , scriptArgs :: [Text]
  }
  deriving (Show, Eq)

instance ToNvimOptions (Maybe LuaScriptOption) where
  toNvimOptions Nothing = []
  toNvimOptions (Just LuaScriptOption{..}) =
    "-l" : [script] <> (T.unpack <$> scriptArgs)

getLuaOptions :: IO LuaOptions
getLuaOptions =
  customExecParser
    (prefs showHelpOnError)
    (info (luaOptsParser <**> helper) idm)

showVersionInfo :: LuaOptions -> Bool
showVersionInfo = optShowVersionInfo

luaOptsParser :: Parser LuaOptions
luaOptsParser =
  LuaOptions
    <$> execOptionParser
    <*> requireOptionParser
    <*> switch
      ( mconcat
          [ short 'v'
          , help "show version information"
          ]
      )
    <*> luaScriptOptionsParser

execOptionParser :: Parser ExecOption
execOptionParser =
  ExecOption
    <$> manyOptionalFields
      ( mconcat
          [ short 'e'
          , help "execute string 'stat'"
          , metavar "stat"
          ]
      )

requireOptionParser :: Parser RequireOption
requireOptionParser =
  RequireOption
    <$> manyOptionalFields
      ( mconcat
          [ short 'l'
          , help
              ( unlines
                  [ "mod: require library 'mod' into global 'mod'"
                  , "g=mod: require library 'mod' into global 'g'"
                  ]
              )
          , metavar "mod"
          ]
      )

luaScriptOptionsParser :: Parser (Maybe LuaScriptOption)
luaScriptOptionsParser = do
  mScript <-
    optional
      ( strArgument
          ( mconcat
              [ metavar "script"
              , help "lua script to run"
              ]
          )
      )
  args <-
    manyOptionalArguments
      ( mconcat
          [ metavar "[args]"
          , help "arguments to pass to the script"
          ]
      )
  pure $ LuaScriptOption <$> mScript <*> pure args

manyOptionalFields :: Mod OptionFields [Text] -> Parser [Text]
manyOptionalFields modifier = mconcat <$> many (option (str <&> T.words) modifier)

manyOptionalArguments :: Mod ArgumentFields [Text] -> Parser [Text]
manyOptionalArguments modifier = mconcat <$> many (argument (str <&> T.words) modifier)
