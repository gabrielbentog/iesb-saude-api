require "test_helper"

class TimeSlotExceptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_slot_exception = time_slot_exceptions(:one)
  end

  test "should get index" do
    get time_slot_exceptions_url, as: :json
    assert_response :success
  end

  test "should create time_slot_exception" do
    assert_difference("TimeSlotException.count") do
      post time_slot_exceptions_url, params: { time_slot_exception: { date: @time_slot_exception.date, end_time: @time_slot_exception.end_time, reason: @time_slot_exception.reason, start_time: @time_slot_exception.start_time, time_slot_id: @time_slot_exception.time_slot_id } }, as: :json
    end

    assert_response :created
  end

  test "should show time_slot_exception" do
    get time_slot_exception_url(@time_slot_exception), as: :json
    assert_response :success
  end

  test "should update time_slot_exception" do
    patch time_slot_exception_url(@time_slot_exception), params: { time_slot_exception: { date: @time_slot_exception.date, end_time: @time_slot_exception.end_time, reason: @time_slot_exception.reason, start_time: @time_slot_exception.start_time, time_slot_id: @time_slot_exception.time_slot_id } }, as: :json
    assert_response :success
  end

  test "should destroy time_slot_exception" do
    assert_difference("TimeSlotException.count", -1) do
      delete time_slot_exception_url(@time_slot_exception), as: :json
    end

    assert_response :no_content
  end
end
