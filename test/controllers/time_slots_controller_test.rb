require "test_helper"

class TimeSlotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_slot = time_slots(:one)
  end

  test "should get index" do
    get time_slots_url, as: :json
    assert_response :success
  end

  test "should create time_slot" do
    assert_difference("TimeSlot.count") do
      post time_slots_url, params: { time_slot: { college_location_id: @time_slot.college_location_id, end_time: @time_slot.end_time, start_time: @time_slot.start_time, turn: @time_slot.turn, week_day: @time_slot.week_day } }, as: :json
    end

    assert_response :created
  end

  test "should show time_slot" do
    get time_slot_url(@time_slot), as: :json
    assert_response :success
  end

  test "should update time_slot" do
    patch time_slot_url(@time_slot), params: { time_slot: { college_location_id: @time_slot.college_location_id, end_time: @time_slot.end_time, start_time: @time_slot.start_time, turn: @time_slot.turn, week_day: @time_slot.week_day } }, as: :json
    assert_response :success
  end

  test "should destroy time_slot" do
    assert_difference("TimeSlot.count", -1) do
      delete time_slot_url(@time_slot), as: :json
    end

    assert_response :no_content
  end
end
