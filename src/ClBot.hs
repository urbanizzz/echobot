module ClBot
  ( getMessage
  , sendMessage
  , sendHelp
  , getRepeat
  ) where

import qualified Data.Aeson                 as A
import qualified Data.Text                  as T
import qualified System.IO                  as IO
import qualified Text.Read                  as Read

import Data.List.Extra                      (lower, trim)
import BotTypes
  ( Event (..)
  , EventEscort (..)
  , UserName (..)
  , UserMessage (..)
  , RepeatNumber (..)
  )

noneUser = UserName . T.pack $ "none"
nullMessage = UserMessage .stringToValue $ ""

getMessage :: IO Event
getMessage = do
  msg <- IO.getLine
  let event = parseMessage msg
  return event

-- todo handle of exceptions
sendMessage :: EventEscort -> IO ()
sendMessage escort = 
  case (valueToString . unUserMessage . userMessage $ escort) of
    Right msg   -> IO.putStrLn $ msg
    Left error  -> IO.putStrLn $ "Error in ClBot.sendMessage: " ++ error

-- todo handle of exceptions
sendHelp :: EventEscort -> A.Value -> IO ()
sendHelp _ helpMsg =
  case valueToString helpMsg of
    Right msg   -> IO.putStrLn $ msg
    Left error  -> IO.putStrLn $ "Error in ClBot.sendHelp: " ++ error

-- todo handle of exceptions
getRepeat :: EventEscort -> RepeatNumber -> A.Value -> IO RepeatNumber
getRepeat _ repeatOld repeatQuestion = do
  case valueToString repeatQuestion of
    Left error  -> do
      IO.putStrLn $ "Error in ClBot.getRepeat: " ++ error
      return $ repeatOld
    Right msg   -> do
      IO.putStrLn msg
      val <- IO.getLine
      case (Read.readMaybe val :: Maybe Int) of
        Nothing   -> return $ repeatOld
        Just rep  -> return $ RepeatNumber rep

parseMessage :: String -> Event
parseMessage msg = case (lower . trim $ msg) of
  "/help"   -> HelpCommand $ Escort noneUser nullMessage
  "/repeat" -> RepeatCommand $ Escort noneUser nullMessage
  otherwise -> Message $ Escort noneUser (UserMessage . stringToValue $ msg)

stringToValue :: String -> A.Value
stringToValue = A.String . T.pack

valueToString :: A.Value -> Either String String
valueToString (A.String str)  = Right . T.unpack $ str
valueToString _               = Left "Value is not (String a)"

