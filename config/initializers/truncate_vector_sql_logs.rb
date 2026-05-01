# frozen_string_literal: true

# Replaces long pgvector literals (e.g. '[0.1, 0.2, ..., -0.3]') in SQL log
# output with a short summary so similarity queries don't dump 1536 dimensions per
# request into development.log.
return unless Rails.env.development?

module TruncateVectorSqlLogs
  VECTOR_LITERAL = /'\[(?<body>[\d\-.,\seE+]{200,})\]'/

  def sql(event)
    sql = event.payload[:sql]
    if sql.is_a?(String) && sql.match?(VECTOR_LITERAL)
      event.payload[:sql] = sql.gsub(VECTOR_LITERAL) do
        nums = Regexp.last_match[:body].split(",")
        preview = nums.first(3).map(&:strip).join(", ")
        "'[#{nums.size} dims: #{preview}, ...]'"
      end
    end
    super
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::LogSubscriber.prepend(TruncateVectorSqlLogs)

  # Hide this file from verbose_query_logs so the "↳ called from" annotation
  # still points at real app code, not our prepended sql wrapper.
  ActiveRecord::LogSubscriber.backtrace_cleaner.add_silencer do |line|
    line.include?("truncate_vector_sql_logs.rb")
  end
end
