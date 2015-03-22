class OrderItem < ActiveRecord::Base
    dragonfly_accessor :image
    
    validates_size_of :image, maximum: 2000.kilobytes,
    message: "should be no more than 500 KB", if: :image_changed?
    
    validates_property :format, of: :image, in: [:jpeg, :jpg, :png, :bmp], case_sensitive: false,
    message: "should be either .jpeg, .jpg, .png, .bmp", if: :image_changed?
    
    dragonfly_accessor :image do
      after_assign { |img| self.image = img.thumb('500x335#') }
    end

end
