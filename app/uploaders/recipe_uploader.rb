class RecipeUploader < CarrierWave::Uploader::Base
  storage :file
  def store_dir
	 'public/my/upload/directory'
  end

  def cache_dir
	  '/tmp/projectname-cache'
  end

  def extension_white_list
	  %w(jpg jpeg gif png)
  end

  version :small_thumb, :from_version => :thumb do
	  process resize_to_fill: [60, 60]
  end

end