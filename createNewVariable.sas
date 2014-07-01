/* Assign file name */
filename f "H:\CHSE\ActiveProjects\Sandbox\RTipsAndTricks\fakedata.csv";

/* Import dataset */
data Work.FakeData;
    length id 8 date 8 state $20 x1 8 x2 8 x3 8;
    format date yymmdd10.;
    informat date yymmdd10.;
    infile f lrecl=100 firstobs=2 dlm="," missover dsd;
    input id date state $ x1 x2 x3;
run;

/* Create new variable, x4 */
data Work.FakeData;
	set Work.FakeData;
	x4 = rantbl(0, 1/5, 1/5, 1/5, 1/5, 1/5);
run;

/* Export dataset */
proc export data=Work.FakeData outfile=f dbms=csv replace;
run;
