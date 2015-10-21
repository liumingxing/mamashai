require File.dirname(__FILE__) + '/../test_helper'
require 'album_template_pages_controller'

# Re-raise errors caught by the controller.
class AlbumTemplatePagesController; def rescue_action(e) raise e end; end

class AlbumTemplatePagesControllerTest < Test::Unit::TestCase
  fixtures :album_template_pages

  def setup
    @controller = AlbumTemplatePagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = album_template_pages(:first).id
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

    assert_not_nil assigns(:album_template_pages)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:album_template_page)
    assert assigns(:album_template_page).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:album_template_page)
  end

  def test_create
    num_album_template_pages = AlbumTemplatePage.count

    post :create, :album_template_page => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_album_template_pages + 1, AlbumTemplatePage.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:album_template_page)
    assert assigns(:album_template_page).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      AlbumTemplatePage.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      AlbumTemplatePage.find(@first_id)
    }
  end
end
