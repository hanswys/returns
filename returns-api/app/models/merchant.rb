class Merchant < ApplicationRecord
  has_many :products, dependent: :destroy # when a merchant is deleted, their products are also deleted
  has_many :orders, dependent: :destroy
  has_many :return_rules, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  validates :name, :email, presence: true # ensures name and email are present # validated when it hits db
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } # checks for valid email format

  enum :status, { active: 0, inactive: 1, suspended: 2 }
end
