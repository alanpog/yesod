{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
module Yesod.Persist
    ( YesodPersist (..)
    , YesodDB
    , get404
    , getBy404
    , module Database.Persist
    , module Database.Persist.TH
    ) where

import Database.Persist
import Database.Persist.TH
import Control.Monad.Trans.Class (MonadTrans (..))
import Control.Monad.IO.Class (MonadIO)
import Control.Failure (Failure)

import Yesod.Handler

type YesodDB sub master = YesodPersistBackend master (GGHandler sub master IO)

class YesodPersist master where
    type YesodPersistBackend master :: (* -> *) -> * -> *
    runDB :: MonadIO monad => YesodDB sub master a -> GGHandler sub master monad a

-- | Get the given entity by ID, or return a 404 not found if it doesn't exist.
get404 :: (PersistBackend t m, PersistEntity val, Monad (t m),
           Failure ErrorResponse m, MonadTrans t)
       => Key t val -> t m val
get404 key = do
    mres <- get key
    case mres of
        Nothing -> lift notFound
        Just res -> return res

-- | Get the given entity by unique key, or return a 404 not found if it doesn't
--   exist.
getBy404 :: (PersistBackend t m, PersistEntity val, Monad (t m),
             Failure ErrorResponse m, MonadTrans t)
         => Unique val t -> t m (Key t val, val)
getBy404 key = do
    mres <- getBy key
    case mres of
        Nothing -> lift notFound
        Just res -> return res
