class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  # relationships: restaurant managers
  has_many :restaurant_managers
  def restaurants
    sql = "SELECT restaurants.* FROM restaurants INNER JOIN restaurant_managers ON restaurants.id = restaurant_managers.restaurant_id WHERE restaurant_managers.manager_id = #{self.id} ORDER BY restaurants.id ASC LIMIT 11"
    #ActiveRecord::Base.connection.execute(sql)
    Restaurant.find_by_sql(sql)
  end

  # relationships: kitchen operators
  has_one :kitchen

  # validations
  enum role: [:manager, :operator, :admin]
end
