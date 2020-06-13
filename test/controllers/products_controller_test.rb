require "test_helper"

describe ProductsController do
  before do
    @merchant_test = merchants(:blacksmith)
    @food_test = categories(:food)
    @product_test = products(:pickles)

    @product_hash = {
      product: {
        name: "Crisp Pickles",
        description: "One jar of homegrown pickles.",
        img_url: "yourmom.com/image.jpeg",
        inventory: 40,
        price: 2,
        category_ids: [categories(:food).id, categories(:lifestyle).id]
      }
    }
  end

  describe "show" do
    it "will get show for valid ids" do
      valid_product = products(:tent)
  
      get "/products/#{valid_product.id}"
  
      must_respond_with :success
    end
  
    it "will respond with not_found for invalid ids" do
      invalid_product_id = -5
  
      get "/products/#{invalid_product_id}"
  
      must_respond_with :not_found
    end
  end
  
  describe "new" do
    it "can get the new_merchant_product_path" do
      get new_merchant_product_path(@merchant_test.id)

      must_respond_with :success
    end

    # it "will redirect to the root if merchant isn't logged in" do
    #  TODO

    # end
  end

  describe "create" do
    it "will redirect to the product show page after creating a product" do
      post merchant_products_path(@merchant_test.id), params: @product_hash
  
      must_respond_with :redirect
      must_redirect_to product_path(Product.last.id)
    end

    it "can create a product with categories with logged in user" do
      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ 'Product.count', 1

      expect(Product.last.name).must_equal @product_hash[:product][:name]
      expect(Product.last.description).must_equal @product_hash[:product][:description]
      expect(Product.last.img_url).must_equal @product_hash[:product][:img_url]
      expect(Product.last.active).must_equal true
      expect(Product.last.inventory).must_equal @product_hash[:product][:inventory]
      expect(Product.last.price).must_equal @product_hash[:product][:price]
      expect(Product.last.merchant).wont_be_nil
      expect(Product.last.merchant.username).must_equal @merchant_test.username

      expect(Product.last.categories).wont_be_nil
      expect(Product.last.categories).wont_be_empty
      expect(Product.last.categories).must_include @food_test
    end

    it "can create a product without categories with logged in user" do
      @product_hash[:product][:category_ids] = []

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ 'Product.count', 1
  
      expect(Product.last.name).must_equal @product_hash[:product][:name]
      expect(Product.last.description).must_equal @product_hash[:product][:description]
      expect(Product.last.img_url).must_equal @product_hash[:product][:img_url]
      expect(Product.last.active).must_equal true
      expect(Product.last.inventory).must_equal @product_hash[:product][:inventory]
      expect(Product.last.price).must_equal @product_hash[:product][:price]
      expect(Product.last.merchant).wont_be_nil
      expect(Product.last.merchant.username).must_equal @merchant_test.username

      expect(Product.last.categories).wont_be_nil
      expect(Product.last.categories).must_be_empty
    end
    
    it "will not create a product with a missing name" do
      @product_hash[:product][:name] = nil

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with a missing description" do
      @product_hash[:product][:description] = nil

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with a missing img_url" do
      @product_hash[:product][:img_url] = nil

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with an invalid inventory" do
      @product_hash[:product][:inventory] = "fifty"

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with a missing inventory" do
      @product_hash[:product][:inventory] = nil

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with an invalid price" do
      @product_hash[:product][:price] = "$25.00"

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end

    it "will not create a product with a missing price" do
      @product_hash[:product][:price] = nil

      expect {
        post merchant_products_path(@merchant_test.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end
  end

  describe "toggle_active" do
    it "can be called upon a product" do

    end

    it "can only be called by the merchant who owns said product" do
    end

    it "will change an active product to inactive" do
      before_state = @product_test.active

      patch toggle_active_path(@product_test.id)
      @product_test.reload

      must_respond_with :redirect
      must_redirect_to products_path(@product_test.id)
      expect(@product_test.active).must_equal !before_state
    end

    it "will change an inactive product to active" do
      inactive_test = products(:inactive_pickles)
      before_state = inactive_test.active

      patch toggle_active_path(inactive_test.id)
      inactive_test.reload

      must_respond_with :redirect
      must_redirect_to products_path(inactive_test.id)
      expect(inactive_test.active).must_equal !before_state
    end
  end
end