class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  # constants
  enum role: [:manager, :kitchen_operator, :admin]

  # relationships: restaurant managers
  has_many :restaurant_managers
  has_many :restaurants, through: :restaurant_managers

  # relationships: kitchen operators
  has_one :kitchen

end
