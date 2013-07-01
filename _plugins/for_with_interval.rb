module Jekyll
  class For < Liquid::For

    def render(context)
      context.registers[:for] ||= Hash.new(0)

      collection = context[@collection_name]
      collection = collection.to_a if collection.is_a?(Range)

      # Maintains Ruby 1.8.7 String#each behaviour on 1.9
      return render_else(context) unless iterable?(collection)

      from = if @attributes['offset'] == 'continue'
        context.registers[:for][@name].to_i
      else
        context[@attributes['offset']].to_i
      end

      limit = context[@attributes['limit']]
      to    = limit ? limit.to_i + from : nil

      interval = context[@attributes['interval']]
      interval = interval ? interval.to_i : 1

      segment = Liquid::Utils.slice_collection_using_each(collection, from, to)
      newsegment = []
      (0..segment.length - 1).step(interval).each do |index|
        newsegment << segment[index]
      end

      segment = newsegment.to_a

      return render_else(context) if segment.empty?

      segment.reverse! if @reversed

      result = ''

      length = segment.length

      # Store our progress through the collection for the continue flag
      context.registers[:for][@name] = from + segment.length

      context.stack do
        segment.each_with_index do |item, index|
          context[@variable_name] = item
          context['forloop'] = {
            'name'    => @name,
            'length'  => length,
            'index'   => index + 1,
            'index0'  => index,
            'rindex'  => length - index,
            'rindex0' => length - index - 1,
            'first'   => (index == 0),
          'last'    => (index == length - 1) }

          result << render_all(@for_block, context)

          # Handle any interrupts if they exist.
          if context.has_interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a? BreakInterrupt
            next if interrupt.is_a? ContinueInterrupt
          end
        end
      end
      result
    end
  end
end

# Liquid::Template.register_tag('for', Jekyll::For)
Liquid::Template.register_tag('for_with_interval', Jekyll::For)