MERGE (t:Term {canonical:'Paracetamol', type:'medication'});
MERGE (b:Brand {name:'Panadol'})-[:BRAND_OF]->(t);
MERGE (ng:Country {iso2:'NG', name:'Nigeria'});
MERGE (b)-[:SOLD_IN]->(ng);
MERGE (en:Language {code:'en', name:'English'});
MERGE (tr:Translation {text:'paracetamol', verified:true});
MERGE (tr)-[:OF_TERM]->(t);
MERGE (tr)-[:IN_LANGUAGE]->(en);