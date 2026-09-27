module SemanticChunks
  class Splitter
    WORD = /[[:alnum:]_]+(?:['-][[:alnum:]_]+)?|[^\s]/.freeze
    SENTENCE_END = /(?<=[.!?])\s+/.freeze
    HEADING = /\A(#{'#'}{1,6})\s+(.+?)\s*\z/.freeze

    attr_reader :max_tokens, :overlap, :min_tokens

    def initialize(max_tokens: 400, overlap: 60, min_tokens: 40)
      raise ArgumentError, "max_tokens must be positive" unless max_tokens.positive?
      raise ArgumentError, "overlap must be non-negative" if overlap.negative?
      raise ArgumentError, "overlap must be smaller than max_tokens" if overlap >= max_tokens

      @max_tokens = max_tokens
      @overlap = overlap
      @min_tokens = min_tokens
    end

    def split(text)
      source = String(text)
      units = semantic_units(source)
      chunks = []
      current = []
      current_tokens = 0
      current_start = nil
      headings = []

      units.each do |unit|
        headings = unit[:headings] if unit[:heading]
        if current.any? && current_tokens + unit[:tokens] > max_tokens
          chunks << build_chunk(chunks.length, current, current_start, headings)
          current, current_tokens, current_start = carry_overlap(current)
        end

        current_start ||= unit[:start]
        current << unit
        current_tokens += unit[:tokens]
      end

      chunks << build_chunk(chunks.length, current, current_start, headings) if current.any?
      merge_small_tail(chunks)
    end

    private

    def semantic_units(text)
      headings = []
      offset = 0
      units = []

      text.each_line do |line|
        line_start = offset
        offset += line.length

        if (match = line.strip.match(HEADING))
          level = match[1].length
          headings = headings.take(level - 1) + [match[2]]
          units << unit(line, line_start, headings, heading: true)
          next
        end

        split_sentences(line).each do |sentence, sentence_start|
          units << unit(sentence, line_start + sentence_start, headings)
        end
      end

      units.reject { |entry| entry[:text].strip.empty? }
    end

    def split_sentences(line)
      cursor = 0
      line.split(SENTENCE_END).map do |sentence|
        start = line.index(sentence, cursor) || cursor
        cursor = start + sentence.length
        [sentence, start]
      end
    end

    def unit(text, start, headings, heading: false)
      {
        text: text,
        start: start,
        finish: start + text.length,
        tokens: token_count(text),
        headings: headings.dup,
        heading: heading
      }
    end

    def token_count(text)
      text.scan(WORD).length
    end

    def carry_overlap(units)
      return [[], 0, nil] if overlap.zero?

      kept = []
      count = 0
      units.reverse_each do |unit|
        break if count + unit[:tokens] > overlap && kept.any?

        kept.unshift(unit)
        count += unit[:tokens]
      end

      [kept, count, kept.first&.fetch(:start)]
    end

    def build_chunk(index, units, start, headings)
      text = units.map { |unit| unit[:text].strip }.reject(&:empty?).join("\n\n")
      chunk_headings = units.reverse.find { |unit| unit[:headings].any? }&.fetch(:headings) || headings

      Chunk.new(
        text: text,
        index: index,
        token_count: token_count(text),
        char_start: start || 0,
        char_end: units.last[:finish],
        headings: chunk_headings,
        metadata: { strategy: "semantic", overlap: overlap, max_tokens: max_tokens }
      )
    end

    def merge_small_tail(chunks)
      return chunks if chunks.length < 2
      return chunks if chunks.last.token_count >= min_tokens

      tail = chunks.pop
      previous = chunks.pop
      merged_text = [previous.text, tail.text].join("\n\n")

      chunks << Chunk.new(
        text: merged_text,
        index: previous.index,
        token_count: token_count(merged_text),
        char_start: previous.char_start,
        char_end: tail.char_end,
        headings: tail.headings.any? ? tail.headings : previous.headings,
        metadata: previous.metadata.merge(merged_tail: true)
      )
    end
  end
end
