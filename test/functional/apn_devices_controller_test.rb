require File.dirname(__FILE__) + '/../test_helper'
require 'apn_devices_controller'

# Re-raise errors caught by the controller.
class ApnDevicesController; def rescue_action(e) raise e end; end

class ApnDevicesControllerTest < Test::Unit::TestCase
  fixtures :apn_devices

  def setup
    @controller = ApnDevicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = apn_devices(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:apn_devices)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:apn_device)
    assert assigns(:apn_device).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:apn_device)
  end

  def test_create
    num_apn_devices = ApnDevice.count

    post :create, :apn_device => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_apn_devices + 1, ApnDevice.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:apn_device)
    assert assigns(:apn_device).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      ApnDevice.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      ApnDevice.find(@first_id)
    }
  end
end
