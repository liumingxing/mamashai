require File.dirname(__FILE__) + '/../test_helper'
require 'album_orders_controller'

# Re-raise errors caught by the controller.
class AlbumOrdersController; def rescue_action(e) raise e end; end

class AlbumOrdersControllerTest < Test::Unit::TestCase
  fixtures :album_orders

  def setup
    @controller = AlbumOrdersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = album_orders(:first).id
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

    assert_not_nil assigns(:album_orders)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:album_order)
    assert assigns(:album_order).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:album_order)
  end

  def test_create
    num_album_orders = AlbumOrder.count

    post :create, :album_order => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_album_orders + 1, AlbumOrder.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:album_order)
    assert assigns(:album_order).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      AlbumOrder.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      AlbumOrder.find(@first_id)
    }
  end
end
