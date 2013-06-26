require 'spec_helper'
require 'rails/generators'
require 'rails/generators/test_case'
require 'rails/generators/mongo_mapper/model/model_generator'

class ModelGeneratorTest < ::Rails::Generators::TestCase

  destination File.expand_path('../../tmp', File.dirname(__FILE__))
  setup :prepare_destination
  tests MongoMapper::Generators::ModelGenerator

  test 'help shows MongoMapper options' do
    content = run_generator ['--help']
    assert_match(/rails generate mongo_mapper:model/, content)
  end

  test 'model are properly created' do
    run_generator ['Color']
    assert_file 'app/models/color.rb', /class Color/
    assert_file 'app/models/color.rb', /include MongoMapper::Document/
  end

  test 'model are properly created with attributes' do
    run_generator ['Color', 'name:string', 'saturation:integer']
    assert_file 'app/models/color.rb', /class Color/
    assert_file 'app/models/color.rb', /include MongoMapper::Document/
    assert_file 'app/models/color.rb', /key :name, String/
    assert_file 'app/models/color.rb', /key :saturation, Integer/
  end

  test 'model are properly created with timestamps option' do
    run_generator ['Color', '--timestamps']
    assert_file 'app/models/color.rb', /class Color/
    assert_file 'app/models/color.rb', /include MongoMapper::Document/
    assert_file 'app/models/color.rb', /timestamps/
  end

  test 'model are properly created with parent option' do
    run_generator ['Green', '--parent', 'Color']
    assert_file 'app/models/green.rb', /class Green < Color/
  end

end
