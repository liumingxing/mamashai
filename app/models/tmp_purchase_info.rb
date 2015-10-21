class TmpPurchaseInfo < ActiveRecord::Base
  validates_presence_of :amount,:money,:pay_person,:receive_person,:address,:postcode,:mobile,:email
end
