posts/show.rabl
collection [@post] => :posts
attributes :id, :title
child @post => :links do
  node(:author)   { @post.author_id }
  node(:comments) { @post.comments_ids }
end
