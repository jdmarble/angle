{-# LANGUAGE TemplateHaskell #-}

module AngleTest (tests) where

import Test.Framework
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.Framework.TH (testGroupGenerator)
import Test.QuickCheck
import Test.QuickCheck.Arbitrary

import Data.Angle
import Data.MetricSpace
import System.Random

tests :: Test
tests = $(testGroupGenerator)


instance (Real a, Floating a) => Bounded (Angle a) where
    minBound = toAngle 0
    maxBound = toAngle (2*pi)

instance (Floating a, Real a, Random a) => Arbitrary (Angle a) where
    arbitrary = arbitraryBoundedRandom


prop_distance_leq_pi a b = distance a b <= pi
    where types = ( a :: Angle Double
                  , b :: Angle Double
                  )

prop_distance_geq_zero a b = distance a b >= 0
    where types = ( a :: Angle Double
                  , b :: Angle Double
                  )

prop_samples_not_all_zero = forAll (vector 10 :: Gen [Angle Double]) $
                            not . and . map ((==0) . fromAngle NegPiPosPi)