module SemanticChunks
  Chunk = Struct.new(:text, :index, :token_count, :char_start, :char_end, :headings, :metadata, keyword_init: true) do
    def to_h
      {
        text: text,
        index: index,
        token_count: token_count,
        char_start: char_start,
        char_end: char_end,
        headings: headings,
        metadata: metadata
      }
    end
  end
end
