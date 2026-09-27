Gem::Specification.new do |spec|
  spec.name = "semantic_chunks"
  spec.version = "0.1.0"
  spec.authors = ["iamzayn19"]
  spec.email = ["iamzayn19@gmail.com"]

  spec.summary = "Pure Ruby semantic text chunking for RAG and LLM apps."
  spec.description = "SemanticChunks splits Markdown and plain text into token-budgeted chunks with overlap, headings, offsets, and metadata without Python dependencies."
  spec.homepage = "https://github.com/iamzayn19/semantic_chunks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/iamzayn19/semantic_chunks/issues",
    "source_code_uri" => "https://github.com/iamzayn19/semantic_chunks"
  }

  spec.files = Dir["lib/**/*", "exe/*", "LICENSE", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["semantic-chunks"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
