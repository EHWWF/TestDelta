This readme.txt is only for the very first DB preparation for ProMIS, e.g. creating USER: IPMS_DATA etc.


1. Check Out trunk/ant and trunk/dev
2. check, change: ant.properties
3. Create users:  
ipms_data
ipms_repo

ant -lib lib -f db.xml users

sophia_import
masterdata
ant -lib lib -f db.xml xusers

Also manually add users that should exists at Bayer side:
create user MXCBI identified by Welcome1;
create user MYCSD identified by Welcome1;

4. Rights
ant -lib lib -f db.xml rights

5. DBLinks
ant -lib lib -f db.xml links

6. Prepare IPMS_DATA for ANT DB script:
ant -lib lib -f db.xml sys_deployment

7. TYPES first
ant -lib lib -f db.xml types

8. TABLES
ant -lib lib -f db.xml tables

9. Do the first run for safe objects = CODE, some of them will compile correctly: TRIGGERS, VIEWS
ant -lib lib -f db.xml code

10. Export and Import oracle user/schema: SOPHIA_IMPORT from another DB

11. Export and Import oracle user/schema: MASTERDATA from another DB

12. VERSIONS
ant -lib lib -f db.xml versions

13. Full DB run:
ant -lib lib -f db.xml update.db