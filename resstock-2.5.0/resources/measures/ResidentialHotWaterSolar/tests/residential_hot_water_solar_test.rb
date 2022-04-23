# frozen_string_literal: true

require_relative '../../../../test/minitest_helper'
require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class ResidentialHotWaterSolarTest < MiniTest::Test
  def test_error_missing_weather
    args_hash = {}
    result = _test_error(nil, args_hash)
    assert_equal(result.errors.map { |x| x.logMessage }[0], 'Model has not been assigned a weather file.')
  end

  def test_error_invalid_azimuth
    args_hash = {}
    args_hash['azimuth'] = -180
    result = _test_error('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash)
    assert_includes(result.errors.map { |x| x.logMessage }, 'Invalid azimuth entered.')
  end

  def test_warning_no_water_heater
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = {}
    expected_values = {}
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 0, 1)
  end

  def test_faces_south_hpwh_hardcoded_volume
    args_hash = {}
    args_hash['storage_vol'] = '80.0'
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => args_hash['storage_vol'].to_f, 'Heater1Setpoint' => 120, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_HPWH.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tankless
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTankless.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_fluid_type_water
    args_hash = {}
    args_hash['fluid_type'] = Constants.FluidWater
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.0, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_azimuth_back_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_azimuth_back_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_azimuth_back_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_azimuth_absolute_west
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 90.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'West', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_azimuth_absolute_west
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 90.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'South', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_azimuth_absolute_west
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 90.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_azimuth_absolute_southwest
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 45.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'Southeast', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_azimuth_absolute_southwest
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 45.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'Northwest', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_azimuth_absolute_southwest
    args_hash = {}
    args_hash['azimuth_type'] = Constants.CoordAbsolute
    args_hash['azimuth'] = 45.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'Southwest', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_tilt_absolute_zero
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'StraightUp', 'Tilt' => 0 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_tilt_absolute_zero
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'StraightUp', 'Tilt' => 0 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_tilt_absolute_zero
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'StraightUp', 'Tilt' => 0 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tilt_absolute_zero
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'StraightUp', 'Tilt' => 0 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_tilt_absolute_thirty
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    args_hash['tilt'] = 30.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 30 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_tilt_absolute_thirty
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    args_hash['tilt'] = 30.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 30 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_tilt_absolute_thirty
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    args_hash['tilt'] = 30.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 30 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tilt_absolute_thirty
    args_hash = {}
    args_hash['tilt_type'] = Constants.CoordAbsolute
    args_hash['tilt'] = 30.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 30 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_tilt_latitude_minus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = -15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 - 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_tilt_latitude_minus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = -15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 - 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_tilt_latitude_minus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = -15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 - 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tilt_latitude_minus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = -15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 - 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_tilt_latitude_plus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = 15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 + 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_tilt_latitude_plus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = 15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 + 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_tilt_latitude_plus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = 15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 + 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tilt_latitude_plus_15_deg
    args_hash = {}
    args_hash['tilt_type'] = Constants.TiltLatitude
    args_hash['tilt'] = 15.0
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => 39.83 + 15 }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_north_tilt_pitch_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_west_tilt_pitch_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_West_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_east_tilt_pitch_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_East_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_tilt_pitch_roof
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_South_GasWHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  def test_faces_south_single_family_attached_new_construction
    num_units = 1
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => num_units, 'ShadingSurface' => num_units, 'SizingPlant' => num_units, 'PumpConstantSpeed' => num_units, 'AvailabilityManagerDifferentialThermostat' => num_units, 'WaterHeaterStratified' => num_units, 'SetpointManagerScheduled' => num_units, 'SolarCollectorFlatPlateWater' => num_units, 'PlantLoop' => num_units, 'SolarCollectorPerformanceFlatPlate' => num_units }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure('SFA_4units_1story_FB_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, num_units * 4)
  end

  def test_faces_south_multifamily_new_construction
    num_units = 1
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => num_units, 'ShadingSurface' => num_units, 'SizingPlant' => num_units, 'PumpConstantSpeed' => num_units, 'AvailabilityManagerDifferentialThermostat' => num_units, 'WaterHeaterStratified' => num_units, 'SetpointManagerScheduled' => num_units, 'SolarCollectorFlatPlateWater' => num_units, 'PlantLoop' => num_units, 'SolarCollectorPerformanceFlatPlate' => num_units }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'StraightUp', 'Tilt' => 0 }
    _test_measure('MF_8units_1story_SL_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, num_units * 4)
  end

  def test_faces_north_retrofit_size
    args_hash = {}
    expected_num_del_objects = {}
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 60, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 40, 'CollectorFlowRate' => 0.0000568724330873, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    model = _test_measure('SFD_2000sqft_2story_FB_GRG_UA_3Beds_2Baths_Denver_WHTank.osm', args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
    args_hash['collector_area'] = 64
    expected_num_del_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_num_new_objects = { 'ShadingSurfaceGroup' => 1, 'ShadingSurface' => 1, 'SizingPlant' => 1, 'PumpConstantSpeed' => 1, 'AvailabilityManagerDifferentialThermostat' => 1, 'WaterHeaterStratified' => 1, 'SetpointManagerScheduled' => 1, 'SolarCollectorFlatPlateWater' => 1, 'PlantLoop' => 1, 'SolarCollectorPerformanceFlatPlate' => 1 }
    expected_values = { 'TankVolume' => 96, 'Heater1Setpoint' => 125, 'Heater2Setpoint' => 125, 'CollectorArea' => 64, 'CollectorFlowRate' => 0.0000909958929397, 'GlycolFrac' => 0.5, 'CoordDir' => 'North', 'Tilt' => UnitConversions.convert(Math.atan(1.0 / 2.0), 'rad', 'deg') }
    _test_measure(model, args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, 4)
  end

  private

  def _test_error(osm_file_or_model, args_hash)
    # create an instance of the measure
    measure = ResidentialHotWaterSolar.new

    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    model = get_model(File.dirname(__FILE__), osm_file_or_model)

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.has_key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result) unless result.value.valueName == 'Fail'

    # assert that it didn't run
    assert_equal('Fail', result.value.valueName)
    assert(result.errors.size == 1)

    return result
  end

  def _test_measure(osm_file_or_model, args_hash, expected_num_del_objects, expected_num_new_objects, expected_values, num_infos = 0, num_warnings = 0, debug = false)
    # create an instance of the measure
    measure = ResidentialHotWaterSolar.new

    # check for standard methods
    assert(!measure.name.empty?)
    assert(!measure.description.empty?)
    assert(!measure.modeler_description.empty?)

    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    model = get_model(File.dirname(__FILE__), osm_file_or_model)

    # get the initial objects in the model
    initial_objects = get_objects(model)

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.has_key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    show_output(result) unless result.value.valueName == 'Success'

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    assert_equal(num_infos, result.info.size)
    assert_equal(num_warnings, result.warnings.size)

    # get the final objects in the model
    final_objects = get_objects(model)

    # get new and deleted objects
    obj_type_exclusions = ['ConnectorMixer', 'Node', 'PipeAdiabatic', 'ConnectorSplitter', 'ScheduleDay', 'ScheduleTypeLimits', 'ScheduleConstant', 'AvailabilityManagerAssignmentList']
    all_new_objects = get_object_additions(initial_objects, final_objects, obj_type_exclusions)
    all_del_objects = get_object_additions(final_objects, initial_objects, obj_type_exclusions)

    # check we have the expected number of new/deleted objects
    check_num_objects(all_new_objects, expected_num_new_objects, 'added')
    check_num_objects(all_del_objects, expected_num_del_objects, 'deleted')

    all_new_objects.each do |obj_type, new_objects|
      new_objects.each do |new_object|
        next if not new_object.respond_to?("to_#{obj_type}")

        new_object = new_object.public_send("to_#{obj_type}").get
        if obj_type == 'WaterHeaterStratified'
          assert_in_epsilon(expected_values['TankVolume'], UnitConversions.convert(new_object.tankVolume.get, 'm^3', 'gal'), 0.01)
          assert_in_epsilon(expected_values['Heater1Setpoint'], UnitConversions.convert(new_object.heater1SetpointTemperatureSchedule.to_ScheduleConstant.get.value, 'C', 'F'), 0.01)
          assert_in_epsilon(expected_values['Heater2Setpoint'], UnitConversions.convert(new_object.heater2SetpointTemperatureSchedule.to_ScheduleConstant.get.value, 'C', 'F'), 0.01)
          assert_in_epsilon(expected_values['CollectorFlowRate'], UnitConversions.convert(new_object.sourceSideDesignFlowRate.get, '', ''), 0.01)
        elsif obj_type == 'ShadingSurface'
          coorddir = nil
          if new_object.outwardNormal.z == 1
            coorddir = 'StraightUp'
          elsif (new_object.outwardNormal.x < 0) && (new_object.outwardNormal.y < 0)
            coorddir = 'Southwest'
          elsif (new_object.outwardNormal.x < 0) && (new_object.outwardNormal.y == 0)
            coorddir = 'West'
          elsif (new_object.outwardNormal.x < 0) && (new_object.outwardNormal.y > 0)
            coorddir = 'Northwest'
          elsif (new_object.outwardNormal.x == 0) && (new_object.outwardNormal.y > 0)
            coorddir = 'North'
          elsif (new_object.outwardNormal.x > 0) && (new_object.outwardNormal.y > 0)
            coorddir = 'Northeast'
          elsif (new_object.outwardNormal.x > 0) && (new_object.outwardNormal.y == 0)
            coorddir = 'East'
          elsif (new_object.outwardNormal.x > 0) && (new_object.outwardNormal.y < 0)
            coorddir = 'Southeast'
          elsif (new_object.outwardNormal.x == 0) && (new_object.outwardNormal.y < 0)
            coorddir = 'South'
          end
          assert_equal(expected_values['CoordDir'], coorddir)
          if new_object.outwardNormal.z == 1
            assert_in_epsilon(expected_values['Tilt'], 0, 0.01)
          else
            assert_in_epsilon(expected_values['Tilt'], UnitConversions.convert(Math.atan(Math.sqrt(new_object.outwardNormal.x**2 + new_object.outwardNormal.y**2) / new_object.outwardNormal.z), 'rad', 'deg'), 0.01)
          end
          assert_in_epsilon(expected_values['CollectorArea'], UnitConversions.convert(new_object.grossArea, 'm^2', 'ft^2'), 0.01)
        elsif obj_type == 'PlantLoop'
          assert_in_epsilon(expected_values['GlycolFrac'], new_object.glycolConcentration * 0.01, 0.01)
        end
      end
    end

    return model
  end
end
