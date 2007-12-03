------------------------------------------------------------------------
-- Uses the integers as the coefficient set
------------------------------------------------------------------------

open import Algebra.Packaged

module Algebra.RingSolver.Int (r : AlmostCommRingoid) where

open import Data.Int
import Algebra.RingSolver as R
import Algebra.Props.AlmostCommRing as A
open A r
open R ℤ-bareRingoid r (ℤ-morphism r) public
