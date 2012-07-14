class Post
  attr :id
  attr :body
  attr :published
  attr :title

  def initialize(args = {})
    @id = 0
    update_attributes(args)
  end

  def update_attributes(args)
    @title = args['title'] if args['title']
    @published = args['published'] if args['published']
    @body = args['body'] if args['body']
  end

  def self.all
    system = Thread.current[:_madeleine_system]
    system['posts'] ||= []
    system['posts']
  end

  def self.find(id_to_find)
    self.all.detect {|post| post.id == id_to_find.to_i}
  end

  def self.model_name
    ActiveModel::Name.new(Post)
  end

  def to_key
    [@id.to_s]
  end

  def to_param
    persisted? ? @id.to_s : nil
  end

  def errors
    # TODO should really be kept?
    ActiveModel::Errors.new(self)
  end

  def persisted?
    @id > 0
  end

  def save
    @id = Post.all.size + 1
    Post.all << self
  end

  def destroy
    Post.all.delete self
  end
end
