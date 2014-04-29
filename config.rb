require 'sass-globbing'

# Require any additional compass plugins here.
project_type = :stand_alone

# Publishing paths
http_path = "/"
http_images_path = "/blog/images"
http_generated_images_path = "/blog/images"
http_fonts_path = "/blog/fonts"
css_dir = "public/stylesheets"

# Local development paths
sass_dir = "sass"
images_dir = "source/images"
fonts_dir = "source/fonts"

if ENV['CSS_DEBUG_MODE'].to_i > 0
  line_comments = true
  output_style = :nested
else
  line_comments = false
  output_style = :compressed
end
