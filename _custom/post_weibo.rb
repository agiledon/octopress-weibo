require 'faraday'
require 'yaml'

class WeiboPoster
  def initialize
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../_config.yml')) 
    @weibo_config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../weibo-config.yml'))    
  end

  def post_weibo
    conn = Faraday.new(:url => "https://api.weibo.com")

    result = conn.post '/2/statuses/update.json',
                       :access_token => @weibo_config['access_token'],
                       :status => generate_post
    puts "post successful"
  end

  private

  def generate_post    
    post_template = @weibo_config['post_template'].force_encoding("utf-8")
    post_template % {:blog_title => latest_blog_title, :blog_url => generate_blog_url }   
  end

  def latest_blog_title
    title_line = IO.readlines(latest_blog_file_name)[2]
    title_line["title: ".length + 1..title_line.length - 3].force_encoding("utf-8")
  end

  def latest_blog_file_name
    blogs_path = File.expand_path(File.dirname(__FILE__) + '/../source/_posts')
    filtered_right_blog = Dir.glob(blogs_path + "/*").select{|f| f.match(/\.markdown/)}
    filtered_right_blog.max_by {|f| File.mtime(f)}
  end

  def generate_blog_url    
    full_url = @config['url'] + "/blog/" + convert_to_blog_url(latest_blog_file_name)
    full_url.force_encoding("utf-8")
  end

  def convert_to_blog_url(post_file_name)
    #convert 2012-12-21-demo-blog.markdown file name to be normal blog url: 2012/12/21/demo-blog
    filename = File.basename(post_file_name, ".markdown")
    filename[4] = "/"
    filename[7] = "/"
    filename[10] = "/"
    filename
  end
end

poster = WeiboPoster.new
poster.post_weibo