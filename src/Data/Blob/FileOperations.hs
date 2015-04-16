{-|
  Module      : Data.Blob.FileOperations
  Description : Contains wrapper for all file operations
  Stability   : Experimental
-}

module Data.Blob.FileOperations where

import qualified Data.ByteString        as B
import           Data.ByteString.Base64 (encode)
import           Data.ByteString.Char8  (unpack)
import           Data.UUID              (toString)
import           Data.UUID.V4           (nextRandom)
import           System.Directory
import           System.FilePath.Posix  ((</>))
import qualified System.IO              as S


-- | Directory for storing partial blobs
tempDir :: FilePath
tempDir = "tmp"

-- | Directory for storing active blobs
activeDir :: FilePath
activeDir = "curr"

-- | Creates a unique file in the temp directory
createUniqueFile :: FilePath -> IO FilePath
createUniqueFile baseDir = do
  filename <- fmap toString nextRandom
  -- Create parent directory if missing
  let parentDir = baseDir </> tempDir
  createDirectoryIfMissing True parentDir
  let absoluteFilePath = parentDir </> filename
  createFile absoluteFilePath
  return absoluteFilePath

-- | Move file to active directory
moveFile :: FilePath -> FilePath -> FilePath -> IO FilePath
moveFile path baseDir filename = do
  let parentDir = baseDir </> activeDir
  createDirectoryIfMissing True parentDir
  let newPath = parentDir </> filename
  renameFile path newPath
  return newPath

-- | Create an empty file.
-- | If the file exists, replace it with an empty file
createFile :: FilePath -> IO ()
createFile path = B.writeFile path B.empty

-- | Open file for writing
openFileForWrite :: FilePath -> IO S.Handle
openFileForWrite path = do
  h <- S.openFile path S.AppendMode
  S.hSetBuffering h S.NoBuffering
  return h

-- | Open file for reading
openFileForRead :: FilePath -> IO S.Handle
openFileForRead path = do
  h <- S.openFile path S.ReadMode
  S.hSetBuffering h S.NoBuffering
  return h

-- | Write contents to a given handle
writeToHandle :: S.Handle -> B.ByteString -> IO ()
writeToHandle = B.hPut

-- | Read contents from a given handle
readFromHandle :: S.Handle -> Int -> IO B.ByteString
readFromHandle = B.hGet

-- | Close the given handle
closeHandle :: S.Handle -> IO ()
closeHandle = S.hClose

-- | Delete the given file
deleteFile :: FilePath -> IO ()
deleteFile = removeFile

-- | Generate a printable file name
toFileName :: B.ByteString -> FilePath
toFileName = unpack . encode
