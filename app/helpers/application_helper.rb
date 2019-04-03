module ApplicationHelper
  MARKDOWN_OPTIONS = {
    link_attributes: {
      rel: 'nofollow',
      target: '_blank'
    },
    hard_wrap: true
  }
  
  MARKDOWN_EXTENSIONS = {
    autolink: true
  }
  
  MARKDOWN_ALLOWED_TAGS = %w(br p b i strong a li ul ol video source pre blockquote)
  MARKDOWN_ALLOWED_ATTRIBUTES = %w(
    preload controls poster type src style class name href title alt height width
  )
  
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(MARKDOWN_OPTIONS)
    markdown = Redcarpet::Markdown.new(renderer, MARKDOWN_EXTENSIONS)
    
    html = markdown.render(text).html_safe
    
    sanitize(html, tags: MARKDOWN_ALLOWED_TAGS, attributes: MARKDOWN_ALLOWED_ATTRIBUTES)
  end
end
