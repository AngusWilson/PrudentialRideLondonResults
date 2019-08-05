
/grab mens results pages, push to files. 186 pages of mens results
{system"curl 'https://results.prudentialridelondon.co.uk/2019/?page=",string[x],"&event=I&event_main_group=A&num_results=100&pid=list&search%5Bsex%5D=M' >> prud",string[x],".txt"} each til 186

/grab womens results pages, push to files. 59 pages of mens results
{system"curl 'https://results.prudentialridelondon.co.uk/2019/?page=",string[x],"&event=I&event_main_group=A&num_results=100&pid=list&search%5Bsex%5D=W' >> prud",string[186+x],".txt"} each 1+til 59


/sanitisation helper func
replaceNull:{ssr[x;"<span class=\"text-m";"-"]}

/function to extract fields from html page into q table
process:{[p;gender]
	names:-3_/:first each  2_/: ">"vs/: p where p like "*list-field type-fullname*";
	rnum:-5_/:first each 3_/:">" vs/: p where p like "*Rider Number*";
	aGroup:replaceNull each -5_/:first each 3_/:">" vs/: p where p like "*Age Group*";
	cClub:replaceNull each -5_/:first each 3_/:">" vs/: p where p like "*Cycling Club*";
	dist:-5_/:first each 3_/:">" vs/: p where p like "*Distance*";
	time:-5_/:first each 3_/:">" vs/: p where p like "*Finish*";

	resTab:([]name:names;time:time;riderNum:rnum;ageGroup:aGroup;club:cClub;distance:dist);
	resTab:1_resTab;
	resTab:update gender:gender from resTab;
	update time:"T"$time from resTab
	}

/func to read file, reflecting naming convention in the curl
readFile:{read0 `$"prud",string[x],".txt"};

/load men and women, assign Gender
men:raze process[;`M] each readFile each 1+til 186;
women:raze process[;`F] each readFile each 187+til 59;

/combine for full set, sanitise columns, order ascending
full:men,women;
full:update nationality:`$-3#/:-1_/:name,`$ageGroup,"I"$riderNum,`$club,distance:{"I"$first " " vs x}each distance from full;
full:`time`name`gender`ageGroup xcols `time xasc update name:-6_/:name from full;

/select out the 100 route
ride100:delete distance from select from full where distance=100;

/Remove results that are clearly wrong
ride100:delete from ride100 where time<03:50:00;

/Add gender results
ride100:update genderPos:1+iasc time by gender from ride100;

/Add age group (and gender) position
ride100:update groupPos:1+iasc time by ageGroup,gender from ride100;
/add finish position
ride100:`position xcols update position:i+1 from ride100;

/Add avg speed (set q console precision to 3 to only give 1 decimal place)
\P 3
ride100:update avgSpeed:160%(`int$`minute$time)%60 from ride100;

ride100
