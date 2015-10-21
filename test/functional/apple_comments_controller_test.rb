require File.dirname(__FILE__) + '/../test_helper'
require 'apple_comments_controller'

# Re-raise errors caught by the controller.
class AppleCommentsController; def rescue_action(e) raise e end; end

class AppleCommentsControllerTest < Test::Unit::TestCase
  fixtures :apple_comments

  def setup
    @controller = AppleCommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = apple_comments(:first).id
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

    assert_not_nil assigns(:apple_comments)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:apple_comment)
    assert assigns(:apple_comment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:apple_comment)
  end

  def test_create
    num_apple_comments = AppleComment.count

    post :create, :apple_comment => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_apple_comments + 1, AppleComment.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:apple_comment)
    assert assigns(:apple_comment).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      AppleComment.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      AppleComment.find(@first_id)
    }
  end
end
