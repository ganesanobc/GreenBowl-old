# GreenBowl

## Objective
Create a food ordering system for restaurants and foodcourts.

---
## Steps
### Phase 1: Create the models and controllers
1. ~~Create project with postgresql.~~
2. Create the Restaurant scaffold (i.e. Restaurant model, RestaurantController and the JSON views).
3. Create the Kitchen scaffold (i.e. Kitchen model, KitchenController and the JSON views).
4. Create the RestaurantManager model
5. Install devise gem and create Customer and Manager tables
6. Customise the user models to match schema (ref: https://github.com/plataformatec/devise/wiki/How-to-Setup-Multiple-Devise-User-Models)
7. db:migrate
8. Create the Category scaffold (i.e. Category model, CategoryController and the JSON views) and update relationships in Restaurant model.
9. Create the Product scaffold (i.e. Product model, ProductController and the JSON views) and update relationships in Kitchen model.
10. Create ProductCategory model and update relationships in Category and Product models.
11. Create the ProductVariant scaffold (i.e. ProductVariant model, ProductVariantController and the JSON views) and update relationships in Product model.
12. Create the Order scaffold (i.e. Order model, OrderController and the ERB views) and update relationships in Customer model.
13. Create the OrderItem scaffold (i.e. OrderItem model, OrderItemController and the JSON views) and update relationships in Order and Kitchen models.
14. Customise the user models to match schema.
15. Install ActiveAdmin for Admin(Devise) and register the following resources: Restaurant, Kitchen, Category, and OrderItem
*NOTE: while Product and ProductVariant models are suppose to be administered within the ActiveAdmin interface we will create a separate interface for them.
Instead we will manipulate them within Kitchen and Category resources*

### Phase 2: Create the ordering system
16. Install ActionCable
17. TODO

---
## Controllers

### RestaurantController
1. index: shows all restaurants
2. show: shows the details of a specific restaurant and lists its categories and kitchens
3. new: provides a new restaurant instance
4. create: assigns the current user as the manager via restaurant_managers association and commits the restaurant instance to database
5. update: commits the changes to the restaurant instance to database

- before_action :authenticated_by_restaurant_manager

### CategoryController
1. index: shows all categories for current restaurant
2. show: shows the details of a specific category  
3. new: provides a new category instance
4. create: assigns the current restaurant as the owner and commits the category instance to database
5. update: commits the changes to the category instance to database

- before_action :authenticated_by_restaurant_manager

### KitchenController
1. index: shows all kitchens for current restaurant
2. show: shows the details of a specific kitchen and includes the assigned kitchen operator and lists all products
3. new: provides a new kitchen instance
4. create: assigns the current restaurant as the owner and commits the kitchen instance to database
5. update: commits the changes to the kitchen instance to database

- before_action :authenticated_by_restaurant_manager
- before_action :authenticated_by_kitchen_operator only:[:show, :edit, :update] -> scoped to the assigned kitchen_operator

### ProductController
1. index: shows all products for current kitchen
2. show: shows the details of a specific product and lists all product variants and categories
3. new: provides a new product instance
4. create: assigns the current kitchen as the owner and commits the product instance to database; also commits any new instances to product category to database
5. update: commits the changes to the product instance to database; also commits any new instances or deletes existing instances to product category to database

- before_action :authenticated_by_restaurant_manager
- before_action :authenticated_by_kitchen_operator -> scoped to the assigned kitchen_operator of the kitchen

### ProductVariantController
1. index: shows all product variants for current product
2. show: shows the details of a specific product variant
3. new: provides a new product variant instance
4. create: assigns the current product as the owner and commits the product variant instance to database
5. update: commits the changes to the product variant instance to database

- before_action :authenticated_by_restaurant_manager
- before_action :authenticated_by_kitchen_operator -> scoped to the assigned kitchen_operator of the kitchen

### OrderController
1. index: shows all orders for current customer
2. show: shows the details of a specific order and lists all its order items  
3. new: provides a new order instance
4. create: assigns the current customer as the owner and commits the order instance to database; It also asks the various order item controllers to starts the notification and payment processes
5. update: commits the changes to the order instance to database

- before_action :authenticated_by_customer, except: [:update]

### OrderItemController
1. index: shows all order items for current kitchen
2. show: shows the details of a specific order item, the associated product and lists all its product variants  
3. new: provides a new order item instance
4. create: assigns the current order and the associated product's kitchen as the owner and commits the order item instance to database; the item should also be registered into the notification register
5. update: commits the changes to the order item instance to database

- before_action :authenticated_by_customer, except: [:update]
- before_action :authenticated_by_kitchen_operator, only: [:update]

---
## Models

### Restaurant
1. brand_name
2. branch_name
3. description:text

* has_many :categories
* has_many :kitchens
* has_many :products through: :kitchens
* has_many :restaurant_managers
* has_many :managers through: :restaurant_managers

### RestaurantManagers
1. belongs_to :restaurant
2. belongs_to :manager

### Kitchen
1. name
2. description:text

- belongs_to :restaurant

* has_many :products
* has_many :order_items
* has_one :kitchen_operator, class_name: managers

### Category
1. title

- belongs_to :restaurant

* has_many :product_categories
* has_many :products through: product_categories

### Product
1. title
2. description:text
3. ingredients:text
4. price:decimal
5. available:integer

* has_many :product_variants
* has_many :product_categories
* has_many :categories through: product_categories

### ProductVariant
1. title
2. description:text
3. add_on_price:decimal
4. available:integer

- belongs_to :product

### ProductCategory
- belongs_to :product
- belongs_to :category

### Order
- belongs_to :customer

* has_many :order_items

### OrderItem
1. quantity:integer
2. state:integer

- belongs_to :order
- belongs_to :kitchen

* has_one :customer through: :order
* has_one :selected_product, class_name: products
* has_many :selected_product_variants, class_name: product_variants

### Customer < Devise
1. first_name
2. last_name
3. mobile_number:integer

* has_many :orders

### Admin < Devise
1. first_name
2. last_name
3. mobile_number:integer
4. role:integer

*for role: restaurant manager*
* has_many :restaurant_managers
* has_many :restaurants through: :restaurant_managers

*for role: kitchen operator*
* has_one :kitchen
* has_many :products through: :kitchen
* has_many :order_items through: :kitchen
