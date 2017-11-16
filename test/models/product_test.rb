require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(:title => "My cool book title",
                          :description => "A good book",
                          :image_url => "hi.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal 'must be greater than or equal to 0.01',
      product.errors[:price].join('; ')

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')

    product.price = 1
    assert product.valid?
  end 

  def new_product(image_url) 
    Product.new(:title => "my cool book title",
                :description => "cool book",
                :price => 1,
                :image_url => image_url)
  end

  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a/ion.gif}
    fail = %W{ fred.doc fred.gif/more fred.gif.more }

    ok.each do | name |
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end 

    fail.each do | name |
      assert new_product(name).invalid?, "#{name} shouldn't be valid"  
    end
  end

  test "product has a unique title" do
    product = Product.new(:title         => products(:ruby).title,
                          :description   => "yyy",
                          :price         => 1,
                          :image_url     => "hi.jpg")
    assert !product.save
    assert_equal "has already been taken",
                 product.errors[:title].join('; ')
  end
end
