require "minitest/autorun"
require "semantic_chunks"

class SemanticChunksTest < Minitest::Test
  def test_splits_markdown_with_headings_and_offsets
    text = <<~MD
      # Intro

      Ruby apps need native document processing. This sentence stays nearby.
      Another sentence gives enough content to split.

      ## Details

      Semantic chunking keeps headings and offsets useful for retrieval.
    MD

    chunks = SemanticChunks.split(text, max_tokens: 16, overlap: 4, min_tokens: 1)

    assert_operator chunks.length, :>=, 2
    assert_equal ["Intro"], chunks.first.headings
    assert chunks.any? { |chunk| chunk.headings == ["Intro", "Details"] }
    assert chunks.all? { |chunk| chunk.char_start <= chunk.char_end }
  end

  def test_overlap_keeps_context
    text = "One two three four five. Six seven eight nine ten. Eleven twelve."

    chunks = SemanticChunks.split(text, max_tokens: 7, overlap: 5, min_tokens: 1)

    assert_operator chunks.length, :>=, 2
    assert_includes chunks[1].text, "One two three four five"
  end

  def test_rejects_invalid_options
    assert_raises(ArgumentError) do
      SemanticChunks.split("hello", max_tokens: 10, overlap: 10)
    end
  end
end
