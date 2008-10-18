class Hash
  def with_indifferent_access
    hash = HashWithIndifferentAccess.new(self)
    hash.default = self.default
    hash
  end
end
class NilClass
  def to_param
    nil
  end
end
