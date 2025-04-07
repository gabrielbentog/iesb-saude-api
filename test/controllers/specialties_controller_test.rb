require "test_helper"

class SpecialtiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @specialty = specialties(:one)
  end

  test "should get index" do
    get specialties_url, as: :json
    assert_response :success
  end

  test "should create specialty" do
    assert_difference("Specialty.count") do
      post specialties_url, params: { specialty: { active: @specialty.active, description: @specialty.description, name: @specialty.name } }, as: :json
    end

    assert_response :created
  end

  test "should show specialty" do
    get specialty_url(@specialty), as: :json
    assert_response :success
  end

  test "should update specialty" do
    patch specialty_url(@specialty), params: { specialty: { active: @specialty.active, description: @specialty.description, name: @specialty.name } }, as: :json
    assert_response :success
  end

  test "should destroy specialty" do
    assert_difference("Specialty.count", -1) do
      delete specialty_url(@specialty), as: :json
    end

    assert_response :no_content
  end
end
