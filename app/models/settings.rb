class Settings < ActiveRecord::Base
    
    validates_size_of :site_logo, maximum: 2000.kilobytes,
    message: "should be no more than 500 KB", if: :site_logo_changed?
    
    validates_property :format, of: :site_logo, in: [:jpeg, :jpg, :png, :bmp], case_sensitive: false,
    message: "should be either .jpeg, .jpg, .png, .bmp", if: :site_logo_changed?
    
    dragonfly_accessor :site_logo do
      after_assign { |img| self.site_logo = img.thumb('500x472#') }
    end
end
