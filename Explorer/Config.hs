{-# LANGUAGE OverloadedStrings #-}

module Explorer.Config
  (
        pgdatabase
      , pghost
      , pgport
      , pguser
      , explorerUrl
      , asRed
      , asGreen
      , asBrown
      , asBlue
      , asPurple
      , asCyan
      , asLightGray
  )
where

-- Postgres access

pgdatabase="bc2sql001"
pghost="localhost"
pgport="5432"
pguser="bc2sql"


-- Explorer
explorerUrl="https://cardanoexplorer.com"
--explorerUrl="http://localhost:8100"


ctl_red="\ESC[31m"
ctl_green="\ESC[32m"
ctl_brown="\ESC[33m"
ctl_blue="\ESC[34m"
ctl_purple="\ESC[35m"
ctl_cyan="\ESC[36m"
ctl_ligray="\ESC[37m"
ctl_closing="\ESC[0m"

asRed :: String -> String
asRed m = ctl_red ++ m ++ ctl_closing

asGreen :: String -> String
asGreen m = ctl_green ++ m ++ ctl_closing

asBrown :: String -> String
asBrown m = ctl_brown ++ m ++ ctl_closing

asBlue :: String -> String
asBlue m = ctl_blue ++ m ++ ctl_closing

asPurple :: String -> String
asPurple m = ctl_purple ++ m ++ ctl_closing

asCyan :: String -> String
asCyan m = ctl_cyan ++ m ++ ctl_closing

asLightGray :: String -> String
asLightGray m = ctl_ligray ++ m ++ ctl_closing

