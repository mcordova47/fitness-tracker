module Types.Measurements.Measurement
  ( Measurement
  , Measurement'
  , MeasurementRaw
  )
  where

import Data.JSDate (JSDate)
import Types.Measurements.BodyPart (BodyPart)

type Measurement = Measurement' JSDate
type MeasurementRaw = Measurement' String

type Measurement' date =
  { bodyPart :: BodyPart
  , date :: date
  , value :: Number
  }
