"""Optional integrity audit: Tableau Hyper records versus MySQL view outputs.
Requires tableauhyperapi. Usage: python3 scripts/audit_tableau.py [mysql flags]
No business metrics are implemented in Python; rows are compared only.
"""
from pathlib import Path
import csv,io,os,sys,subprocess,tempfile,zipfile,xml.etree.ElementTree as ET,json
from tableauhyperapi import HyperProcess,Telemetry,Connection
from verify_exports import SOURCES,compare,ROOT

def main():
 mapping={name.replace('(1)','').removesuffix('.csv'):(view,keys) for name,(view,keys) in SOURCES.items()}
 summary=[]
 for workbook in ['customer_engagement.twbx','customer_engagement_reviewed.twbx']:
  with zipfile.ZipFile(ROOT/'dashboard'/workbook) as z,tempfile.TemporaryDirectory(prefix='eh-') as temp:
   assert z.testzip() is None
   r=ET.fromstring(z.read(next(n for n in z.namelist() if n.endswith('.twb'))))
   with HyperProcess(Telemetry.DO_NOT_SEND_USAGE_DATA_TO_TABLEAU,parameters={'domain_socket_dir':temp,'log_dir':temp}) as h:
    for d in r.findall('./datasources/datasource'):
     e=d.find('./extract/connection')
     if e is None:continue
     name=d.get('caption');view,keys=mapping[name]
     path=Path(temp)/Path(e.get('dbname')).name;path.write_bytes(z.read(e.get('dbname')))
     with Connection(h.endpoint,str(path)) as c:
      table=c.catalog.get_table_names('Extract')[0]
      cols=[col.name.unescaped for col in c.catalog.get_table_definition(table).columns]
      actual=[dict(zip(cols,['' if v is None else str(v) for v in row])) for row in c.execute_list_query(f'SELECT * FROM {table}')]
     query='SELECT '+','.join('`'+x+'`' for x in cols)+' FROM '+view
     cmd=[os.environ.get('MYSQL_BIN','mysql'),*sys.argv[1:],'--database=customer_engagement','--batch','--raw','--execute='+query]
     expected=list(csv.DictReader(io.StringIO(subprocess.run(cmd,check=True,capture_output=True,text=True).stdout),delimiter='\t'))
     keydiff,valuediff,duplicates=compare(actual,expected,cols,keys)
     expected_diff=0 if 'reviewed' in workbook else 18524 if name=='student_buckets_f2p' else 12181 if name=='student_learning' else 0
     assert keydiff==0 and duplicates==0 and len(actual)==len(expected) and valuediff==expected_diff,(workbook,name,valuediff)
     summary.append({'workbook':workbook,'source':name,'hyper_rows':len(actual),'mysql_rows':len(expected),'key_mismatches':keydiff,'value_mismatches':valuediff,'expected_known_mismatches':expected_diff})
 with (ROOT/'docs/qa/tableau_mysql_reconciliation.csv').open('w') as f:
  writer=csv.DictWriter(f,fieldnames=summary[0]);writer.writeheader();writer.writerows(summary)
 print('PASS: reviewed workbook all 10 sources reconcile; original has 2 documented source defects.')
if __name__=='__main__':main()
