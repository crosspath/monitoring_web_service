module ApplicationHelper
  include NewsHelper

  def markdown(text)
    options = { link_attributes: { rel: 'nofollow', target: '_blank' }, hard_wrap: true }
    extensions = { autolink: true }
    tags = %w(br p b i strong a li ul ol video source)
    attributes = %w(preload controls poster type src style class name href title alt height width)

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    html = markdown.render(text).html_safe
    sanitize(html, tags: tags, attributes: attributes)
  end
end
