{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}

module Data.Angle
    ( Angle
    , toAngle
    , fromAngle
    , AngleRange (..)
    ) where

import Data.Fixed (mod')
import Data.AdditiveGroup
import Data.MetricSpace
import Data.VectorSpace
import System.Random


newtype (Floating a, Real a) => Angle a = Angle a
    deriving (Eq)


toAngle :: (Floating a, Real a) => a -> Angle a
toAngle a = Angle $ mod' a (2*pi)


data AngleRange = ZeroTwoPi | NegPiPosPi

fromAngle :: (Floating a, Real a) => AngleRange -> Angle a -> a
fromAngle ZeroTwoPi (Angle a) = a
fromAngle NegPiPosPi (Angle a) | a <= pi   = a
                               | otherwise = a - 2*pi


instance (Floating a, Real a, Show a) => Show (Angle a) where
    show = show . fromAngle ZeroTwoPi


instance (Floating a, Real a) => AdditiveGroup (Angle a) where
    zeroV = Angle 0
    Angle a ^+^ Angle b = toAngle $ a + b
    negateV (Angle a) = toAngle $ negate a


instance (Floating a, Real a) => VectorSpace (Angle a) where
    type Scalar (Angle a) = a
    s *^ (Angle v) = toAngle $ s * v


instance (Floating a, Real a) => MetricSpace (Angle a) where
    type Metric (Angle a) = a
    distance (Angle a) (Angle b)
        | x > pi    = 2*pi - x
        | otherwise = x
        where
          x = abs $ b - a

instance (Floating a, Real a, Random a) => Random (Angle a) where
    randomR (Angle 0, Angle 0) g = random g
    randomR (Angle l, Angle h) g = (toAngle a, g')
        where (a, g') = randomR (l, h) g
    random g = (toAngle $ a * 2 * pi, g')
        where (a, g') = random g
