# frozen_string_literal: true

# Generates db/schema_reference.rb as a human-readable companion to
# db/structure.sql. The structure.sql file remains the canonical schema
# (loaded by Rails, captures Postgres-specific features like triggers /
# views / RLS that schema.rb can't represent). schema_reference.rb is
# regenerated automatically whenever you run `bin/rails db:schema:dump`.

namespace :db do
  namespace :schema do
    desc "Dump db/schema_reference.rb (human-readable companion to structure.sql)"
    task reference: :environment do
      path = Rails.root.join("db/schema_reference.rb")

      File.open(path, "w:utf-8") do |file|
        file.puts <<~HEADER
          # AUTO-GENERATED — DO NOT EDIT
          # ============================
          # This file is regenerated whenever you run `bin/rails db:schema:dump`.
          # The canonical schema is db/structure.sql; this file exists as a
          # human-readable companion view for quick reference. If you spot a
          # discrepancy, structure.sql is the truth — Rails' schema dumper can't
          # represent every Postgres feature (triggers, RLS, custom types, etc.).
          #
        HEADER
        ActiveRecord::SchemaDumper.dump(ApplicationRecord.connection_pool, file)
      end

      puts "✓ Generated #{path.relative_path_from(Rails.root)}"
    end
  end
end

# Auto-regenerate db/schema_reference.rb whenever structure.sql is dumped.
Rake::Task["db:schema:dump"].enhance do
  Rake::Task["db:schema:reference"].invoke
end
