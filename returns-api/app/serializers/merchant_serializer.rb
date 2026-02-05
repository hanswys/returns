class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :contact_person, :address, :status, :created_at, :updated_at

  has_many :products
  has_many :orders
  has_many :return_rules
end
