"""Optional Tableau packaging repair; all metrics come from the shipped MySQL views.
Requires tableauhyperapi. Preserves original TWBX and writes a separately named reviewed copy.
Usage: python3 scripts/repair_tableau.py [mysql connection flags]
"""
from pathlib import Path
import csv,io,os,sys,re,json,zipfile,hashlib,tempfile
import subprocess,xml.etree.ElementTree as ET
from datetime import date
from tableauhyperapi import HyperProcess,Telemetry,Connection,CreateMode,TableDefinition,TableName,SqlType,Inserter
ROOT=Path(__file__).resolve().parents[1]

def main():
 original=ROOT/'dashboard/customer_engagement.twbx'
 original_hash=hashlib.sha256(original.read_bytes()).hexdigest()
 refresh=ROOT/'review_materials/tableau_refresh';refresh.mkdir(exist_ok=True)
 specs={
 'student_learning':('ce_learning',[('student_id',SqlType.big_int()),('date_watched',SqlType.date()),('minutes_watched',SqlType.double()),('paid',SqlType.big_int())]),
 'student_buckets_f2p':('ce_f2p',[('student_id',SqlType.big_int()),('date_registered',SqlType.date()),('f2p',SqlType.big_int()),('total_minutes_watched',SqlType.double()),('buckets',SqlType.text())])}
 with zipfile.ZipFile(original) as z:
  twb=next(n for n in z.namelist() if n.endswith('.twb'))
  xml=z.read(twb).decode('utf-8');root=ET.fromstring(xml)
  paths={d.get('caption'):d.find('./extract/connection').get('dbname') for d in root.findall('./datasources/datasource') if d.find('./extract/connection') is not None}
  replacements={};counts={}
  # Temporary work only. Telemetry disabled; no upload or publication.
  with tempfile.TemporaryDirectory(prefix='edu-tableau-') as temp:
   with HyperProcess(Telemetry.DO_NOT_SEND_USAGE_DATA_TO_TABLEAU,parameters={'domain_socket_dir':temp,'log_dir':temp}) as h:
    for caption,(view,columns) in specs.items():
     names=[c[0] for c in columns]
     query='SELECT '+','.join('`'+c+'`' for c in names)+' FROM '+view
     cmd=[os.environ.get('MYSQL_BIN','mysql'),*sys.argv[1:],'--batch','--raw','--database=customer_engagement','--execute='+query]
     output=subprocess.run(cmd,check=True,capture_output=True,text=True).stdout
     records=list(csv.DictReader(io.StringIO(output),delimiter='\t'))
     with (refresh/(caption+'.csv')).open('w') as f:
      w=csv.DictWriter(f,fieldnames=names);w.writeheader();w.writerows(records)
     target=Path(temp)/(caption+'.hyper')
     table=TableDefinition(TableName('Extract','Extract'),[TableDefinition.Column(n,t) for n,t in columns])
     data=[]
     for r in records:
      data.append([date.fromisoformat(r[n]) if n.startswith('date_') else float(r[n]) if 'minutes' in n else r[n] if n=='buckets' else int(r[n]) for n in names])
     with Connection(h.endpoint,str(target),CreateMode.CREATE_AND_REPLACE) as c:
      c.catalog.create_schema('Extract');c.catalog.create_table(table)
      with Inserter(c,table) as inserter:inserter.add_rows(data);inserter.execute()
      assert c.execute_scalar_query('SELECT COUNT(*) FROM "Extract"."Extract"')==len(records)
      if caption=='student_learning':assert abs(float(c.execute_scalar_query('SELECT SUM(minutes_watched) FROM "Extract"."Extract"'))-1917374.91)<.01
      else:assert c.execute_scalar_query('SELECT COUNT(*) FROM "Extract"."Extract" WHERE total_minutes_watched IS NULL')==0
     replacements[paths[caption]]=target.read_bytes();counts[caption]=len(records)
   # Minimal text changes preserve all layout, filters, calculated fields and action XML.
   xml,n_columns=re.subn(r"(<column\b[^>]*datatype=')integer('[^>]*name='\[total_minutes_watched\]'[^>]*/>)",r'\1real\2',xml)
   def metadata(m):
    s=m.group(0)
    if '<remote-name>total_minutes_watched</remote-name>' in s and '<local-type>integer</local-type>' in s:
     s=s.replace('<remote-type>20</remote-type>','<remote-type>5</remote-type>').replace('<local-type>integer</local-type>','<local-type>real</local-type>').replace('<contains-null>true</contains-null>','<contains-null>false</contains-null>')
    return s
   xml=re.sub(r'<metadata-record class=\'column\'>.*?</metadata-record>',metadata,xml,flags=re.S)
   # Remove cached thumbnails: they represent OLD data and must not masquerade as new renders.
   xml=re.sub(r'\s*<thumbnails>.*?</thumbnails>','',xml,flags=re.S)
   # Corrected CSV sources can be rebound locally if the author chooses to refresh.
   for caption in specs:
    xml=re.sub(r"(<connection class='textscan' directory=')[^']*(' filename='"+caption+r"\.csv')",r'\1../review_materials/tableau_refresh\2',xml)
   ET.fromstring(xml)
   reviewed=ROOT/'dashboard/customer_engagement_reviewed.twbx'
   with zipfile.ZipFile(reviewed,'w',zipfile.ZIP_DEFLATED) as out:
    for name in z.namelist():out.writestr(name,xml.encode('utf-8') if name==twb else replacements.get(name,z.read(name)))
 with zipfile.ZipFile(reviewed) as z:assert z.testzip() is None
 assert hashlib.sha256(original.read_bytes()).hexdigest()==original_hash
 log={'original_sha256':original_hash,'reviewed_sha256':hashlib.sha256(reviewed.read_bytes()).hexdigest(),'updated_extract_rows':counts,'f2p_column_declarations_changed':n_columns,'cached_thumbnails_removed':True,'original_unchanged':True,'layout_or_calculation_changes':False,'visual_rendering_status':'Requires Tableau visual revalidation; original preview thumbnails are not reviewed-copy screenshots.'}
 (ROOT/'docs/qa/tableau_repair.json').write_text(json.dumps(log,indent=2)+'\n')
 print(json.dumps(log,indent=2))
if __name__=='__main__':main()
