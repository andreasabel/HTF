{-# OPTIONS_GHC -XTemplateHaskell -cpp -pgmPcpphs -optP --cpp -optP -include -optP HTF.h #-}

import System.Environment ( getArgs )
import Test.Framework

{-
myReverse :: [a] -> [a]
myReverse [] = []
myReverse [x] = [x]
myReverse (x:xs) = myReverse xs
-}

myReverse :: [a] -> [a]
myReverse [] = []
myReverse (x:xs) = myReverse xs ++ [x]

$(tests "reverseTests" [d|

  test_nonEmpty = do assertEqual [1] (myReverse [1])
                     assertEqual [3,2,1] (myReverse [1,2,3])
  test_empty = assertEqual ([] :: [Int]) (myReverse [])

  prop_reverse :: [Int] -> Bool
  prop_reverse xs = xs == (myReverse (myReverse xs))

  prop_reverseReplay = 
    withQCArgs (\a -> a { replay = read "Just (1060394807 2147483396,2)" })
    prop_reverse

  |])

main = 
    do args <- getArgs
       runTestWithArgs args reverseTests