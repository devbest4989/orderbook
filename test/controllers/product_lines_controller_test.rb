require 'test_helper'

class ProductLinesControllerTest < ActionController::TestCase
  setup do
    @product_line = product_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_line" do
    assert_difference('ProductLine.count') do
      post :create, product_line: { name: @product_line.name }
    end

    assert_redirected_to product_line_path(assigns(:product_line))
  end

  test "should show product_line" do
    get :show, id: @product_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product_line
    assert_response :success
  end

  test "should update product_line" do
    patch :update, id: @product_line, product_line: { name: @product_line.name }
    assert_redirected_to product_line_path(assigns(:product_line))
  end

  test "should destroy product_line" do
    assert_difference('ProductLine.count', -1) do
      delete :destroy, id: @product_line
    end

    assert_redirected_to product_lines_path
  end
end
