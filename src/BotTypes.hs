module BotTypes where

import qualified Data.Map.Lazy              as M
import qualified Data.Text                  as T
import qualified Data.Aeson                 as A 

import Data.Scientific            (coefficient)


data BotType
  = CL
  | TG
  | VK
  deriving (Eq, Ord, Show)

newtype BotToken      = BotToken      {unBotToken     :: T.Text}
newtype UserName      = UserName      {unUserName     :: T.Text}
  deriving (Eq, Ord)
newtype RepeatNumber  = RepeatNumber  {unRepeatNumber :: Int}
newtype UsersRepeat   = UsersRepeat   {unUsersRepeat  :: M.Map UserName RepeatNumber}
newtype UserMessage   = UserMessage   {unUserMessage  :: A.Value}

instance A.FromJSON BotType where
  parseJSON = A.withText "FromJSON Types.BotType" $ \t ->
    case t of
      "cl" -> pure CL
      "vk" -> pure VK
      "tg" -> pure TG
      _    -> fail $ "Unknown type of bot in config: " ++ T.unpack t

instance A.FromJSON BotToken where
  parseJSON = A.withText "FromJSON Types.BotToken" $ return . BotToken

instance A.FromJSON RepeatNumber where
  parseJSON = A.withScientific "FromJSON Types.RepeatNumber" $ return . RepeatNumber . fromInteger . coefficient

data Event  = HelpCommand EventEscort
            | RepeatCommand EventEscort
            | Message EventEscort

data EventEscort = Escort
  { userName    :: UserName
  , userMessage :: UserMessage
  }

