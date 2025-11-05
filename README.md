# Project Codex — Translation & Country-Specific Brands

## How to set up PostgreSQL (GUI)
1) Install Postgres.app (Mac) or pgAdmin.
2) Create database `codex`.
3) Open Query Tool / Open psql.
4) Run `sql/schema_and_seed.sql`.
5) Verify:
   SELECT t.canonical AS term, c.iso2 AS country, b.brand
   FROM brand_names b
   JOIN terms t ON t.id=b.term_id
   JOIN countries c ON c.id=b.country_id
   ORDER BY term,country;
   => Expect: Paracetamol/US/Tylenol and Paracetamol/NG/Panadol.

Fuzzy demo:
SELECT brand, similarity(brand,'tylenal') AS score
FROM brand_names
WHERE similarity(brand,'tylenal')>0.3
ORDER BY score DESC;
=> Expect: Tylenol ~ 0.45

## How to set up Neo4j (GUI)
1) Install Neo4j Desktop, create DBMS 5.x, password `codex`, start it.
2) Click Open Browser (http://localhost:7474), login neo4j/codexcodex.
3) Run:
   :use neo4j
   (paste contents of neo4j/seed.cypher)
4) Verify with:
   MATCH (t:Term)-[:BRAND_OF]-(b:Brand) RETURN t,b;
   MATCH (b:Brand {name:'Panadol'})-[:SOLD_IN]->(c:Country) RETURN b,c;
   MATCH (t:Term {canonical:'Paracetamol'})<-[:OF_TERM]-(tr:Translation)-[:IN_LANGUAGE]->(l:Language) RETURN t,tr,l;

## Folder map
- docs/    (screenshots for sprint)
- sql/     (Postgres schema and seed)
- neo4j/   (Cypher seed)
