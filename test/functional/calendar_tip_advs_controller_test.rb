require File.dirname(__FILE__) + '/../test_helper'
require 'calendar_tip_advs_controller'

# Re-raise errors caught by the controller.
class CalendarTipAdvsController; def rescue_action(e) raise e end; end

class CalendarTipAdvsControllerTest < Test::Unit::TestCase
  fixtures :calendar_tip_advs

  def setup
    @controller = CalendarTipAdvsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = calendar_tip_advs(:first).id
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

    assert_not_nil assigns(:calendar_tip_advs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:calendar_tip_adv)
    assert assigns(:calendar_tip_adv).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:calendar_tip_adv)
  end

  def test_create
    num_calendar_tip_advs = CalendarTipAdv.count

    post :create, :calendar_tip_adv => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_calendar_tip_advs + 1, CalendarTipAdv.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:calendar_tip_adv)
    assert assigns(:calendar_tip_adv).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      CalendarTipAdv.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      CalendarTipAdv.find(@first_id)
    }
  end
end
