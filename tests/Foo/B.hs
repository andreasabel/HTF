{-# OPTIONS_GHC -F -pgmF ./dist/build/htfpp/htfpp #-}

module Foo.B (htf_thisModulesTests) where

import qualified Test.Framework as HTF

test_b = assertEqual 1 1
