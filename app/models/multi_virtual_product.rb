class MultiVirtualProduct < VirtualProduct
  def type_name
    "多用户(#{self.person_amount})"
  end
end