class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  with_options dependent: :destroy do |customer|
    customer.has_one :salesforce_account
    customer.has_many :nocrm_steps
    customer.has_many :nocrm_field_types
    customer.has_many :nocrm_attributes
    customer.has_many :nocrm_webhooks
    customer.has_many :salesforce_fields
    customer.has_many :salesforce_stages
  end

  has_secure_token :webhooks_token

  def current_tenant!
    ActsAsTenant.current_tenant = self
  end

  def create_nocrm_attributes
    ActsAsTenant.with_tenant(self) do
      nocrm_att_seed_file = File.join(Rails.root, 'db', 'nocrm_attributes.yml')
      config = YAML::load_file(nocrm_att_seed_file)
      NocrmAttribute.create(config["nocrm_attributes"])
    end
  end

  def has_connected_nocrm?
    nocrm_account.present? && api_key.present?
  end
end
