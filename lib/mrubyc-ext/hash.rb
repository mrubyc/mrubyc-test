class Hash
  def add_by_key(key)
    if self.has_key?(key)
      self[key] =+ 1
    else
      self[key] = 1
    end
  end
end

