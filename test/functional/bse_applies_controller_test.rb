require File.dirname(__FILE__) + '/../test_helper'
require 'bse_applies_controller'

# Re-raise errors caught by the controller.
class BseAppliesController; def rescue_action(e) raise e end; end

class BseAppliesControllerTest < Test::Unit::TestCase
  fixtures :bse_applies

  def setup
    @controller = BseAppliesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = bse_applies(:first).id
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

    assert_not_nil assigns(:bse_applies)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:bse_apply)
    assert assigns(:bse_apply).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:bse_apply)
  end

  def test_create
    num_bse_applies = BseApply.count

    post :create, :bse_apply => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_bse_applies + 1, BseApply.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:bse_apply)
    assert assigns(:bse_apply).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      BseApply.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      BseApply.find(@first_id)
    }
  end
end
