=begin
#weg-li Recommender API

#No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)

The version of the OpenAPI document: 0.1.0

Generated by: https://openapi-generator.tech
OpenAPI Generator version: 5.0.1

=end

require 'spec_helper'
require 'json'

# Unit tests for OpenapiClient::ReportApi
# Automatically generated by openapi-generator (https://openapi-generator.tech)
# Please update as you see appropriate
describe 'ReportApi' do
  before do
    # run before each test
    @api_instance = OpenapiClient::ReportApi.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of ReportApi' do
    it 'should create an instance of ReportApi' do
      expect(@api_instance).to be_instance_of(OpenapiClient::ReportApi)
    end
  end

  # unit tests for report_district_zipcode_get
  # @param zipcode 
  # @param [Hash] opts the optional parameters
  # @return [InlineResponse2002]
  describe 'report_district_zipcode_get test' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for report_post
  # @param inline_object1 
  # @param [Hash] opts the optional parameters
  # @return [nil]
  describe 'report_post test' do
    it 'should work' do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

end