require 'test_helper'

class Mms::SosoControllerTest < ActionController::TestCase
  test "should get test" do
    get :test
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
