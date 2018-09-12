spool /oracle/dba/log/masker.log
@/oracle/dba/sql/disable_trigger.sql
@/oracle/dba/sql/unusable_indexes.sql
@/oracle/dba/sql/disable_constraints.sql
alter system set job_queue_processes=200;
exec sys.dbms_xstream_gg.set_foo_trigger_session_contxt(fire=>true);
set serveroutput on
set timing on
BEGIN
  DBMS_PARALLEL_EXECUTE.drop_task('MASKE');
END;
/
BEGIN
  DBMS_PARALLEL_EXECUTE.create_task (task_name => 'MASKE');
END;
/

BEGIN
  DBMS_PARALLEL_EXECUTE.create_chunks_by_rowid(task_name   => 'MASKE',
                                               table_owner => 'SYSADM',
                                               table_name  => 'CUSTOMER_ALL',
                                               by_row      => TRUE,
                                               chunk_size  => 5000);
END;
/

DECLARE
  l_sql_stmt VARCHAR2(12000);
BEGIN
  dbms_output.put_line('start :'||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')); 
  l_sql_stmt := 'UPDATE sysadm.customer_all c
   SET c.mothers_name = decode(mothers_name ,null,null,''ANNEADI''),
       c.csremark_1 = decode(csremark_1 ,null,null,''BABAADI''),
       c.csremark_2 = decode(csremark_2 ,null,null,''ANNEKIZLIK''),
       c.birth_place_district = decode(birth_place_district ,null,null,''ANKARA''),
       c.birth_place_province = decode(birth_place_province ,null,null,''ANKARA''),
       c.registered_province = decode(registered_province ,null,null,''ANKARA''),
       c.registered_district = decode(registered_district ,null,null,''ANKARA''),
       c.cstcidnumber = decode(cstcidnumber ,null,null,trunc(dbms_random.value(10000000000, 80000000000)))
       WHERE rowid BETWEEN :start_id AND :end_id';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => 'MASKE',
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 128);
commit;
END;
/


BEGIN
  DBMS_PARALLEL_EXECUTE.drop_task('MASKE');
END;
/
BEGIN
  DBMS_PARALLEL_EXECUTE.create_task (task_name => 'MASKE');
END;
/

BEGIN
  DBMS_PARALLEL_EXECUTE.create_chunks_by_rowid(task_name   => 'MASKE',
                                               table_owner => 'SYSADM',
                                               table_name  => 'CCONTACT_ALL',
                                               by_row      => TRUE,
                                               chunk_size  => 5000);
END;
/

DECLARE
  l_sql_stmt VARCHAR2(12000);
BEGIN
  l_sql_stmt := 'UPDATE sysadm.ccontact_all a
   SET a.cscomptaxno = decode(cscomptaxno ,null,null,ora_hash(customer_id)),
       a.passportno = decode(passportno ,null,null,''U''||ora_hash(customer_id+1)),
       a.ccstreet = decode(ccstreet ,null,null,''ANKARA''),
       a.ccstreetno = decode(ccstreetno ,null,null,''No:0/0''),
       a.cccity = decode(cccity ,null,null,''ANKARA-ANKARA''),
       a.cczip = decode(cczip ,null,null,''00000''),
       a.ccadditional = decode(ccadditional ,null,null,NULL),
       a.ccaddr1 = decode(ccaddr1 ,null,null,''ANKARA''),
       a.ccaddr2 = decode(ccaddr2 ,null,null,''No:0/0''),
       a.ccaddr3 = decode(ccaddr3 ,null,null,''Anne adi: ANNEADI''),
       a.cctn = decode(cctn ,null,null,trunc(dbms_random.value(1000000, 9999999))),
       a.cctn2 = decode(cctn2 ,null,null,trunc(dbms_random.value(1000000, 9999999))),
       a.ccfax = decode(ccfax ,null,null,trunc(dbms_random.value(1000000, 9999999))),
       a.ccline1 = decode(ccline1 ,null,null,''ADI-SOYADI''), 
       a.ccline2 = decode(ccline2 ,null,null,''ANKARA''),
       a.ccline3 = decode(ccline3 ,null,null,''No:0/0''),
       a.ccline4 = decode(ccline4 ,null,null,''ANKARA''),
       a.ccline5 = decode(ccline5 ,null,null,''00000 ANKARA''),
       a.ccemail = decode(ccemail ,null,null,''dummy@bb.zz''),
       a.csdrivelicence = decode(csdrivelicence ,null,null,ora_hash(customer_id+2)),
       a.ccname = decode(ccname ,null,null,case when ccname is not null then ''ADI-SOYADI'' else ccname end),
       a.birthdate = decode(birthdate ,null,null,TRUNC (birthdate, ''YYYY'')),
       a.cclnamemc = decode(cclnamemc ,null,null,''SYD''),
       a.ccjobdesc = decode(ccjobdesc ,null,null,''IS''),
       a.cssocialsecno = decode(cssocialsecno ,null,null,ora_hash(customer_id+3))
       WHERE rowid BETWEEN :start_id AND :end_id';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => 'MASKE',
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 128);
commit;
END;
/

BEGIN
  DBMS_PARALLEL_EXECUTE.drop_task('MASKE');
END;
/
BEGIN
  alter table sysadm.CCONTACT_ALL enable constraint PKCCONTACT_ALL;
  alter index sysadm.PKCCONTACT_ALL rebuild parallel 32;
  alter index sysadm.PKCCONTACT_ALL noparallel;
  DBMS_PARALLEL_EXECUTE.create_task (task_name => 'MASKE');
END;
/

BEGIN
  DBMS_PARALLEL_EXECUTE.create_chunks_by_rowid(task_name   => 'MASKE',
                                               table_owner => 'SYSADM',
                                               table_name  => 'CCONTACT_ALL_SFL01',
                                               by_row      => TRUE,
                                               chunk_size  => 5000);
END;
/

DECLARE
  l_sql_stmt VARCHAR2(12000);
BEGIN
  l_sql_stmt := 'MERGE INTO sysadm.ccontact_all a
     USING (SELECT *
              FROM sysadm.ccontact_all_sfl01 x
             WHERE x.ROWID BETWEEN :start_id AND :end_id) b
        ON (a.customer_id = b.customer_id AND a.ccseq = b.ccseq)
WHEN MATCHED
THEN
    UPDATE SET a.ccfname = b.ccfname0, a.cclname = b.cclname0';

  DBMS_PARALLEL_EXECUTE.run_task(task_name      => 'MASKE',
                                 sql_stmt       => l_sql_stmt,
                                 language_flag  => DBMS_SQL.NATIVE,
                                 parallel_level => 64);
commit;
dbms_output.put_line('end :'||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')); 
END;
/
drop table sysadm.CCONTACT_ALL_SFL01;
@/oracle/dba/sql/enable_trigger.sql
@/oracle/dba/sql/rebuild_indexes.sql
@/oracle/dba/sql/enable_constraints.sql
spool off;
exit

