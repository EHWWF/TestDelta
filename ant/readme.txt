---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--ADF Excel templates (e.g.: LE/LTC files)
---------------------------------------------------------------------------------------------
Before starting ADF deployment make sure that 3 excel files from the location: "...\dev\application\view\public_html\excel\" 
where not changed since last deployment.
If changed, then you must send to BHC for signing using BHC certificate.
Otherwise some functions/features could not work, e.g. Excel Macros will be disabled.
After having signed files just commit it to SVN (simply replace existing once).
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
1.	Check “ant.properties” should have only environment-relevant data.
---------------------------------------------------------------------------------------------
2.	Check out “trunk/dev” manually using TortoiseUI client
---------------------------------------------------------------------------------------------
3.	Compile the code (all "make" or separately e.g.: "make.app"):
---------------------------------------------------------------------------------------------
ant -lib lib make.mds
ant -lib lib make.mw
ant -lib lib make.app
---------------------------------------------------------------------------------------------
4.	Just for testing (not mandatory) do the test SOA deployment, to check if the connections are OK. NOTE: It only installs SOA test project. No impact for ProMIS.
---------------------------------------------------------------------------------------------
ant -lib lib -f wls.xml deploy.test
---------------------------------------------------------------------------------------------
5.	Install (update) DB. Start DB update in the bacground while continuing on other tasks.
---------------------------------------------------------------------------------------------
ant -lib lib -f db.xml update.db
---------------------------------------------------------------------------------------------
6.	After DB part is done re-view DB log file from the folder "ant/log". Open the one that is the most recent and has the biggest size.
---------------------------------------------------------------------------------------------
open file and search for word: error
---------------------------------------------------------------------------------------------
7. Chcek if all DB objects are still valid, at ipms_Data and ipms_repo db user.
---------------------------------------------------------------------------------------------
select * from user_objects where status<>'VALID' and object_name not like 'EXPORT_%';
---------------------------------------------------------------------------------------------
8. Make sure if DB Jobs are running. If not then run from ANT:
---------------------------------------------------------------------------------------------
ant -lib lib -f db.xml start_jobs
---------------------------------------------------------------------------------------------
9.	Redeploy MDS if needed
---------------------------------------------------------------------------------------------
ant -lib lib -f wls.xml deploy.mds
---------------------------------------------------------------------------------------------
10.	Redeploy all MW compoistes or just selected once, e.g. "soa", "bpm",...
---------------------------------------------------------------------------------------------
ant -lib lib -f wls.xml deploy.mw
---------------------------------------------------------------------------------------------
or just SOA (just one composite):
---------------------------------------------------------------------------------------------
ant -lib lib -f wls.xml deploy.soa
---------------------------------------------------------------------------------------------
11.	Redeploy ADF
---------------------------------------------------------------------------------------------
ant -lib lib -f wls.xml deploy.app
---------------------------------------------------------------------------------------------
12.	Restart WebLogic 2 managed servers:
---------------------------------------------------------------------------------------------
a) adf_server1
b) soa_server1
---------------------------------------------------------------------------------------------
13. Go to ProMIS UI and perform "read timeline" for selected project. Just for testing if the main parts are working fine.
---------------------------------------------------------------------------------------------