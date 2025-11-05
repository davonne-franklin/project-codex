-- Extensions: add fuzzy matching capability
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Reference tables
CREATE TABLE IF NOT EXISTS languages (
  id SERIAL PRIMARY KEY, code TEXT UNIQUE NOT NULL, name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS countries (
  id SERIAL PRIMARY KEY, iso2 CHAR(2) UNIQUE NOT NULL, name TEXT NOT NULL
);

-- Canonical medical terms (one per concept)
CREATE TABLE IF NOT EXISTS terms (
  id SERIAL PRIMARY KEY,
  canonical TEXT UNIQUE NOT NULL,
  code TEXT,
  term_type TEXT NOT NULL CHECK (term_type IN ('symptom','diagnosis','medication','dosage'))
);

-- Translations users see
CREATE TABLE IF NOT EXISTS translations (
  id SERIAL PRIMARY KEY,
  term_id INT REFERENCES terms(id),
  language_id INT REFERENCES languages(id),
  text TEXT NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  CONSTRAINT translations_unique UNIQUE (term_id,language_id,text)
);

-- Country-specific brand names
CREATE TABLE IF NOT EXISTS brand_names (
  id SERIAL PRIMARY KEY,
  term_id INT REFERENCES terms(id),
  country_id INT REFERENCES countries(id),
  brand TEXT NOT NULL,
  CONSTRAINT brand_names_unique UNIQUE (term_id,country_id,brand)
);

-- Indexes for fuzzy search
CREATE INDEX IF NOT EXISTS idx_terms_trgm        ON terms        USING gin (canonical gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_translations_trgm ON translations USING gin (text gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_brand_trgm        ON brand_names  USING gin (brand gin_trgm_ops);

-- Seed minimal data
INSERT INTO languages(code,name) VALUES ('en','English') ON CONFLICT DO NOTHING;
INSERT INTO countries(iso2,name) VALUES ('US','United States'),('NG','Nigeria') ON CONFLICT DO NOTHING;

INSERT INTO terms(canonical,term_type) VALUES
  ('headache','symptom'),
  ('Paracetamol','medication')
ON CONFLICT DO NOTHING;

INSERT INTO translations(term_id,language_id,text,verified)
  SELECT t.id,l.id,'headache',TRUE
  FROM terms t,languages l
  WHERE t.canonical='headache' AND l.code='en'
  ON CONFLICT DO NOTHING;

INSERT INTO brand_names(term_id,country_id,brand)
  SELECT t.id,c.id,'Tylenol'
  FROM terms t,countries c
  WHERE t.canonical='Paracetamol' AND c.iso2='US'
  ON CONFLICT DO NOTHING;

INSERT INTO brand_names(term_id,country_id,brand)
  SELECT t.id,c.id,'Panadol'
  FROM terms t,countries c
  WHERE t.canonical='Paracetamol' AND c.iso2='NG'
  ON CONFLICT DO NOTHING;