# encoding: utf-8

class BlockElementUploader < BaseImageUploader

  # Create different versions of your uploaded files:
  version :full do
    process resize_to_fill: [100, 100]
  end

  version :thumb do
    process resize_to_fit: [160, 160]
  end

end
