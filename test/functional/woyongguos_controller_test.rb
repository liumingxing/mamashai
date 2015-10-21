require File.dirname(__FILE__) + '/../test_helper'
require 'woyongguos_controller'

# Re-raise errors caught by the controller.
class WoyongguosController; def rescue_action(e) raise e end; end

class WoyongguosControllerTest < Test::Unit::TestCase
  fixtures :woyongguos

  def setup
    @controller = WoyongguosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = woyongguos(:first).id
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

    assert_not_nil assigns(:woyongguos)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:woyongguo)
    assert assigns(:woyongguo).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:woyongguo)
  end

  def test_create
    num_woyongguos = Woyongguo.count

    post :create, :woyongguo => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_woyongguos + 1, Woyongguo.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:woyongguo)
    assert assigns(:woyongguo).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Woyongguo.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Woyongguo.find(@first_id)
    }
  end
end
