require 'test_helper'

class ConfigOptsControllerTest < ActionController::TestCase
  setup do
    @config_opt = config_opts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:config_opts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create config_opt" do
    assert_difference('ConfigOpt.count') do
      post :create, :config_opt => @config_opt.attributes
    end

    assert_redirected_to config_opt_path(assigns(:config_opt))
  end

  test "should show config_opt" do
    get :show, :id => @config_opt.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @config_opt.to_param
    assert_response :success
  end

  test "should update config_opt" do
    put :update, :id => @config_opt.to_param, :config_opt => @config_opt.attributes
    assert_redirected_to config_opt_path(assigns(:config_opt))
  end

  test "should destroy config_opt" do
    assert_difference('ConfigOpt.count', -1) do
      delete :destroy, :id => @config_opt.to_param
    end

    assert_redirected_to config_opts_path
  end
end
