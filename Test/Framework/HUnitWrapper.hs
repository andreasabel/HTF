--
-- Copyright (c) 2005, 2009   Stefan Wehr - http://www.stefanwehr.de
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA
--

module Test.Framework.HUnitWrapper (

  assertBool_, assertEqual_, assertEqualNoShow_, assertNotEmpty_, assertEmpty_,
  assertSetEqual_, assertThrows_,

  assertFailure

) where

import System.IO ( stderr )
import Data.List ( (\\) )
import Control.Exception
import Control.Monad
import qualified Test.HUnit as HU hiding ( assertFailure )

import Test.Framework.TestManager
import Test.Framework.Location
import Test.Framework.Utils

--
-- Assertions
--

-- WARNING: do not forget to add a preprocessor macro for new assertions!!

assertFailure :: String -> IO ()
assertFailure s = unitTestFail s

assertBool_ :: Location -> Bool -> HU.Assertion
assertBool_ loc False = assertFailure ("assert failed at " ++ showLoc loc)
assertBool_ loc True = return ()

assertEqual_ :: (Eq a, Show a) => Location -> a -> a -> HU.Assertion
assertEqual_ loc expected actual =
    if expected /= actual
       then assertFailure msg
       else return ()
    where msg = "assertEqual failed at " ++ showLoc loc ++
                "\n expected: " ++ show expected ++ "\n but got:  " ++ 
                show actual

assertEqualNoShow_ :: Eq a => Location -> a -> a -> HU.Assertion
assertEqualNoShow_ loc expected actual =
    if expected /= actual
       then assertFailure ("assertEqualNoShow failed at " ++ showLoc loc)
       else return ()

assertSetEqual_ :: (Eq a, Show a) => Location -> [a] -> [a] -> HU.Assertion
assertSetEqual_ loc expected actual =
    let ne = length expected
        na = length actual
        in case () of
            _| ne /= na ->
                 assertFailure ("assertSetEqual failed at " ++ showLoc loc
                                ++ "\n expected length: " ++ show ne
                                ++ "\n actual length: " ++ show na)
             | not (unorderedEq expected actual) ->
                 assertFailure ("assertSetEqual failed at " ++ showLoc loc
                                ++ "\n expected: " ++ show expected
                                ++ "\n actual: " ++ show actual)
             | otherwise -> return ()
    where unorderedEq l1 l2 =
              null (l1 \\ l2) && null (l2 \\ l1)


assertNotEmpty_ :: Location -> [a] -> HU.Assertion
assertNotEmpty_ loc [] = 
    assertFailure ("assertNotNull failed at " ++ showLoc loc)
assertNotEmpty_ _ (_:_) = return ()

assertEmpty_ :: Location -> [a] -> HU.Assertion
assertEmpty_ loc (_:_) = assertFailure ("assertNull failed at " ++ showLoc loc)
assertEmpty_ loc [] = return ()

assertThrows_ :: Exception e => Location -> IO a -> (e -> Bool) -> HU.Assertion
assertThrows_ loc io f =
    do res <- try io
       case res of
         Right _ -> assertFailure ("assertThrows failed at " ++ showLoc loc ++
                                   ": no exception was thrown")
         Left e -> if f e then return ()
                   else assertFailure ("assertThrows failed at " ++
                                       showLoc loc ++
                                       ": wrong exception was thrown: " ++
                                       show e)