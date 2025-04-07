require "test_helper"

class CollegeLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @college_location = college_locations(:one)
  end

  test "should get index" do
    get college_locations_url, as: :json
    assert_response :success
  end

  test "should create college_location" do
    assert_difference("CollegeLocation.count") do
      post college_locations_url, params: { college_location: { location: @college_location.location, name: @college_location.name } }, as: :json
    end

    assert_response :created
  end

  test "should show college_location" do
    get college_location_url(@college_location), as: :json
    assert_response :success
  end

  test "should update college_location" do
    patch college_location_url(@college_location), params: { college_location: { location: @college_location.location, name: @college_location.name } }, as: :json
    assert_response :success
  end

  test "should destroy college_location" do
    assert_difference("CollegeLocation.count", -1) do
      delete college_location_url(@college_location), as: :json
    end

    assert_response :no_content
  end
end
