class NocrmWebhook < ApplicationRecord
  acts_as_tenant :customer
end
