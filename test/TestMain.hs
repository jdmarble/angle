module Main where

import Test.Framework

import qualified AngleTest

main :: IO ()
main = defaultMain
       [ AngleTest.tests
       ]
