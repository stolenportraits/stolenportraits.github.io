require 'open-uri'

module Jekyll
  module URLFilter
    def urlencode(input)
      URI::encode(input)
    end
  end
end

Liquid::Template.register_filter(Jekyll::URLFilter)