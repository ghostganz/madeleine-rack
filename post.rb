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

  def self.all(system)
    system['posts'] ||= []
    system['posts']
  end

  def self.find(system, id_to_find)
    system['posts'] ||= []
    system['posts'].detect {|post| post.id == id_to_find.to_i}
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
    # TODO should really be kept
    ActiveModel::Errors.new(self)
  end

  def persisted?
    @id > 0
  end

  def save(system)
    system['posts'] ||= []
    @id = system['posts'].size + 1
    system['posts'] << self
  end

  def destroy(system)
    system['posts'].delete self
  end
end
