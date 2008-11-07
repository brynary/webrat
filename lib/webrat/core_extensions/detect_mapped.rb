class Array #:nodoc:
  
  def detect_mapped
    each do |element|
      result = yield element
      return result if result
    end
    
    return nil
  end
  
end