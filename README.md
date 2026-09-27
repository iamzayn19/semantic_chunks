# SemanticChunks

SemanticChunks is a pure Ruby text chunker for RAG, search indexing, and LLM apps.

It solves a common Ruby AI problem: document preparation often gets pushed to Python just to split text into useful chunks. This gem keeps that step in Ruby.

## Install

```bash
gem install semantic_chunks
```

## Usage

```ruby
require "semantic_chunks"

chunks = SemanticChunks.split(markdown, max_tokens: 300, overlap: 40)

chunks.each do |chunk|
  puts chunk.text
  p chunk.metadata
end
```

Each chunk includes:

- `text`
- `index`
- `token_count`
- `char_start`
- `char_end`
- `headings`
- `metadata`

## CLI

```bash
semantic-chunks README.md --max-tokens 300 --overlap 40
```

Outputs JSON.

## Why

Ruby has excellent web frameworks and backend tooling, but a lot of AI utility work still assumes Python. SemanticChunks gives Ruby apps a native, predictable chunking layer before embeddings, vector search, or LLM calls.
