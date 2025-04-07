require "test_helper"

class ConsultationRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consultation_room = consultation_rooms(:one)
  end

  test "should get index" do
    get consultation_rooms_url, as: :json
    assert_response :success
  end

  test "should create consultation_room" do
    assert_difference("ConsultationRoom.count") do
      post consultation_rooms_url, params: { consultation_room: { active: @consultation_room.active, college_location_id: @consultation_room.college_location_id, name: @consultation_room.name, specialty_id: @consultation_room.specialty_id } }, as: :json
    end

    assert_response :created
  end

  test "should show consultation_room" do
    get consultation_room_url(@consultation_room), as: :json
    assert_response :success
  end

  test "should update consultation_room" do
    patch consultation_room_url(@consultation_room), params: { consultation_room: { active: @consultation_room.active, college_location_id: @consultation_room.college_location_id, name: @consultation_room.name, specialty_id: @consultation_room.specialty_id } }, as: :json
    assert_response :success
  end

  test "should destroy consultation_room" do
    assert_difference("ConsultationRoom.count", -1) do
      delete consultation_room_url(@consultation_room), as: :json
    end

    assert_response :no_content
  end
end
