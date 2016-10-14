class ImageProcessor
  include ChunkyPNG

  def self.combine_images(base_image, top_image, x, y)
    unless base_image.class == Image
      base = Image.from_file(base_image)
    else
      base = base_image
    end
    
    unless top_image.class == Image
      top = Image.from_file(top_image)
    else
      top = top_image
    end

    base.compose!(top, x, y)
    return base
  end

  def self.resize(src, width, height)
    return src.resample_bilinear(width, height)
  end
  
end
