# frozen_string_literal: true

class PublicStatusesIndex < Chewy::Index
  settings index: index_preset(refresh_interval: '30s', number_of_shards: 5), analysis: {
    filter: {
      english_stop: {
        type: 'stop',
        stopwords: '_english_',
      },

      english_stemmer: {
        type: 'stemmer',
        language: 'english',
      },

      english_possessive_stemmer: {
        type: 'stemmer',
        language: 'possessive_english',
      },
    },

    analyzer: {
      verbatim: {
        char_filter: %w(icu_normalizer),
        tokenizer: 'kuromoji_tokenizer',
        filter: %w(
          lowercase
          kuromoji_baseform
          kuromoji_part_of_speech
          cjk_width
          ja_stop
          kuromoji_stemmer
          english_stemmer
        ),
      },

      content: {
        char_filter: %w(icu_normalizer),
        tokenizer: 'kuromoji_tokenizer',
        filter: %w(
          lowercase
          kuromoji_baseform
          kuromoji_part_of_speech
          cjk_width
          ja_stop
          kuromoji_stemmer
          english_stemmer
        ),
      },

      hashtag: {
        tokenizer: 'keyword',
        filter: %w(
          word_delimiter_graph
          lowercase
          asciifolding
          cjk_width
        ),
      },
    },
  }

  index_scope ::Status.unscoped
                      .kept
                      .indexable
                      .includes(:media_attachments, :preloadable_poll, :preview_cards, :tags)

  root date_detection: false do
    field(:id, type: 'long')
    field(:account_id, type: 'long')
    field(:text, type: 'text', analyzer: 'verbatim', value: ->(status) { status.searchable_text }) { field(:stemmed, type: 'text', analyzer: 'content') }
    field(:tags, type: 'text', analyzer: 'hashtag', value: ->(status) { status.tags.map(&:display_name) })
    field(:language, type: 'keyword')
    field(:properties, type: 'keyword', value: ->(status) { status.searchable_properties })
    field(:created_at, type: 'date')
  end
end
