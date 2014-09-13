module Utils (print64, randoms64, linToRF, rfToLin, random64ToSquare, bitScanForward) where

import Types
import Data.Bits
import System.Random as Rand
import Data.Array.Unboxed as UArray

linToRF :: Int -> (Int, Int)
linToRF sq = quotRem sq 8

rfToLin :: Int -> Int -> Int
rfToLin rank file = rank*8 + file

print64 :: BB -> IO ()
print64 b = let l64 = replicate 64 b
                shifts = 1:(take 63 (map (shift 1) [1..])) :: [BB]
                inter = zipWith (.&.) shifts l64
                result = (map fromIntegral) $ zipWith shift inter (map (*(-1))[0..63]) :: [Int]
            in printLikeABoardIterate 0 result


printLikeABoardIterate :: Int -> [Int] -> IO ()
printLikeABoardIterate 64 _ = putStr "\n"
printLikeABoardIterate i xs = do let realIndex = \a -> 64 - 8*( truncate ((fromIntegral (a+8))/8) ) + (a `rem` 8) :: Int
                                 if i `rem` 8 == 0
                                     then putStr $ "\n"
                                     else return ()
                                 let x = (xs !! (realIndex i))
                                 putStr $ ( show x ) ++ " "
                                 printLikeABoardIterate (i+1) xs

randoms64 :: Int -> [BB]
randoms64 = fromRandoms . Rand.randoms . mkStdGen

random64ToSquare :: BB -> Int
random64ToSquare r = abs(fromIntegral r) `rem` 64

fromRandoms :: [Int] -> [BB]
fromRandoms (a:b:c:xs) = (    (fromIntegral a) 
	                      .|. (shiftL (fromIntegral b) 30)
                          .|. (shiftL (fromIntegral c) 60) ):(fromRandoms xs)

index64 :: UArray BB Int
index64 = UArray.listArray (0,63) [0,  1, 48,  2, 57, 49, 28,  3,
                                   61, 58, 50, 42, 38, 29, 17,  4,
                                   62, 55, 59, 36, 53, 51, 43, 22,
                                   45, 39, 33, 30, 24, 18, 12,  5,
                                   63, 47, 56, 27, 60, 41, 37, 16,
                                   54, 35, 52, 21, 44, 32, 23, 11,
                                   46, 26, 40, 15, 34, 20, 31, 10,
                                   25, 14, 19,  9, 13,  8,  7,  6]

bitScanForward :: BB -> Int
bitScanForward bb = let debruijn64 = 0x03f79d71b4cb0a89 :: BB
                    in index64 UArray.! (((bb .&. (-bb)) * debruijn64) `shiftR` 58)
