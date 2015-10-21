require File.dirname(__FILE__) + '/../test_helper'
require 'week_tags_controller'

# Re-raise errors caught by the controller.
class WeekTagsController; def rescue_action(e) raise e end; end

class WeekTagsControllerTest < Test::Unit::TestCase
  fixtures :week_tags

  def setup
    @controller = WeekTagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = week_tags(:first).id
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

    assert_not_nil assigns(:week_tags)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:week_tag)
    assert assigns(:week_tag).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:week_tag)
  end

  def test_create
    num_week_tags = WeekTag.count

    post :create, :week_tag => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_week_tags + 1, WeekTag.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:week_tag)
    assert assigns(:week_tag).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      WeekTag.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      WeekTag.find(@first_id)
    }
  end
end
