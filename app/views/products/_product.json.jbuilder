json.extract! product, :id, :title, :description, :ingredients, :price, :available, :created_at, :updated_at
json.url product_url(product, format: :json)
