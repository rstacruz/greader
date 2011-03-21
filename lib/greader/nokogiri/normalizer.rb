require 'nokogiri'

module Nokogiri
  # Normalizer
  #
  # == Example
  #   
  #   Normalizer.normalize '<p>Hello</p><a>  </a><h3 style="lol">hi</h3>thth<p><img></p>'
  #   Normalizer.normalize node
  #
  module Normalizer
    extend self

    BLOCK  = %w(p h1 h2 h3 h4 h5 h6 dl dt dd)
    INLINE = %w(a span strong em b i)
    
    # Normalizes HTML by cleaning out common mistakes.
    def normalize(node)
      return normalize_str(node)  if node.is_a?(String)

      html = node.dup

      remove_style_attrs! html
      wrap_stray_text! html

      blocks(html).each do |blk|
        blk.remove  if blank?(blk)
        add_class blk, 'image'  if image_paragraph?(blk)
      end

      html
    end

    def normalize_str(str)
      normalize(Nokogiri.HTML(str)).xpath('//body').children.to_s
    end

    def blocks(html)
      html.css((INLINE+BLOCK).join(','))
    end

    def add_class(html, cls)
      html['class'] = [html['class'], 'image'].compact.join(' ')
    end

    # @example
    #   "<p><img></p>"        #=> true
    #   "<p>hello <img></p>"  #=> false
    #
    def image_paragraph?(html)
      html.css('*').size == html.css('img').size && html.text.strip == ''
    end

    # @example
    #   "<p>  \n</p>"   #=> true
    #
    def blank?(html)
      html.text.strip == '' && html.css('*').empty?
    end

    # @example
    #   "<a style='display:block'></a>"  # => "<a></a>"
    #
    def remove_style_attrs!(html)
      html.xpath('//@style').remove
    end

    # @example
    #   "<p>hi</p>hello"  # => "<p>hi</p><p>hello</p>"
    #
    def wrap_stray_text!(html)
      html.xpath('//body/text()').each do |text|
        text.add_next_sibling "<p>#{text}</p>"
        text.remove
      end
    end
  end
end
