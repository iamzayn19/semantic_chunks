require_relative "semantic_chunks/chunk"
require_relative "semantic_chunks/splitter"
require_relative "semantic_chunks/version"

module SemanticChunks
  class Error < StandardError; end

  def self.split(text, **options)
    Splitter.new(**options).split(text)
  end
end
