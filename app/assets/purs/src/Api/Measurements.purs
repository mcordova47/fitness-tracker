module Api.Measurements
  ( measurements
  )
  where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as Affjax
import Data.Either (hush)
import Data.JSDate as JSDate
import Data.Maybe (Maybe)
import Data.Traversable (for)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Types.Measurements.Measurement (Measurement, MeasurementRaw)
import Unsafe.Coerce (unsafeCoerce)

measurements :: String -> Aff (Maybe (Array Measurement))
measurements userId = do
  raw <- Affjax.get ResponseFormat.json $ "/" <> userId <> "/measurements/measurements"
  for (hush raw) \{ body } ->
    for (unsafeCoerce body :: _ MeasurementRaw) \measurement -> do -- TODO: Use argonaut instead of `unsafeCoerce`
      date <- liftEffect $ JSDate.parse measurement.date
      pure measurement { date = date }
