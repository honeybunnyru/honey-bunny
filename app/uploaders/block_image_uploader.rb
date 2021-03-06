# encoding: utf-8

class BlockImageUploader < BaseImageUploader

  # Create different versions of your uploaded files:
  version :full do
    process resize_to_limit: [1920, nil]
  end

  version :middle do
    process resize_to_limit: [780, nil]
  end

  version :thumb do
    process resize_to_limit: [480, nil]
  end

end
