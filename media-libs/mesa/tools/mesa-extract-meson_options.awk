BEGIN {
	RS="[=[:space:]]+option\\(";
	FS="";
	ORS="";
	prefix="mesa";
	iuselist=""
};

NR > 1 {
	parens=1;
	start=1;
	for ( c=1; c <= NF; c++) {
		if( $c  == "(" ) { ++parens; };
		if ( $c == ")" ) { end=c-1 ; --parens;};
		if(parens==0) {
			o=substr($0,start,end);
			gsub(/\n/," ", o);
			gsub(/[[:space:]]+/," ", o);
			gsub(/^[[:space:]]+/, "", o);
			gsub(/[[:space:]]+$/, "", o);
			comma=index(o,",");
			optname=substr(o,2,comma-3);

			od=substr(o,comma+1);
			gsub(/^[[:space:]]/, "", od);

			optdata[optname]=od;
			#print("\nOptname: " optname "\n");
			#print(optdata[optname] "\n");
			break;
		};
	};
	$0=$0;
};

function _UC_(mytext,   mytmp) {
	mytmp=mytext;
	gsub(/-/,"_", mytmp);
	mytmp=toupper(mytmp);
	return(mytmp);
};

function print_ebuild_iuse(opttype,optname,optchoices,optvalue,    myoptnum,myoptchoices,myoptchoice) {
	if(opttype=="boolean" || (optchoices ~ /auto/ && optchoices ~ /true/ && optchoices ~ /false/)) {
		if(optvalue=="true") {mydef="+"; } else {mydef=""};
		printf("IUSE_%s_%s=\"%s%s_%s\"\n", _UC_(prefix), _UC_(optname), mydef, prefix, optname);
	} else if (opttype=="array" || opttype=="combo") {
		myoptchoicenum=split(optchoices,myoptchoices,",");
		printf("IUSE_%s_%s=\"", _UC_(prefix), _UC_(optname));
		iuselist=iuselist " ${IUSE_" _UC_(prefix) "_" _UC_(optname) "}" ;
		n=0
		for (i=1;i<=myoptchoicenum;i++) {
			myoptchoice=myoptchoices[i];
			gsub(/[' ]/,"",myoptchoice);
			if ( myoptchoice == "" || myoptchoice == "auto" ) { continue; };
			if (++n>1) { printf " "; };
			printf("%s_%s_%s", prefix, optname, myoptchoice);
		};
		printf("\"\n");
	} else {
	};

};

function print_ebuild_define_string(opttype,optname,optchoices,optvalue) {
	if(opttype=="string" || opttype=="integer") {
		printf("%s_%s=\"%s\"\n", _UC_(prefix), _UC_(optname), optvalue);
	} else {
	};
}

END {

	for(o in optdata) {
		od=optdata[o];
		while(od != "") {
			comma=0;
			colon=0;
			bracket=0;
			arr="";
			val="";

			colon=index(od,":");
			tag=substr(od,1,colon-1);
			gsub(/^[[:space:]]+/, "", tag);
			gsub(/[[:space:]]+$/, "", tag);
	
			od=substr(od,colon+1);
			gsub(/^[[:space:]]+/, "", od);

			comma=index(od,",");
			quote=index(od,"'");
			bracket=index(od,"[");

			if( ( comma > bracket ) && match(od,"\\[[^\\]]*\\]") ) {
				arr=substr(od,RSTART+1,RLENGTH-2);
				od=substr(od,RSTART+RLENGTH);
				gsub(/[[:space:]]+$/, "", od);
				comma=index(od,",");
				val=arr;
			} else if ( (quote > 0 ) && ((comma > quote) || (comma < 1) ) ) {
				for(t=quote+1; t<=length(od); t++ ) {
					if( ( substr(od,t,1) == "'" ) && ( substr(od,t-1,1) != "\\" ) ) {
						val=substr(od,quote+1,(t-quote)-1);
						od=substr(od,t+1);
						gsub(/[[:space:]]+$/, "", od);
						comma=index(od,",");
						break;
					}
				}
			}

			if(comma > 0) {
				if (val == "" ) { val=substr(od,1,comma-1); }
				od=substr(od,comma + 1);
			} else {
				if (val == "" ) { val=od; };
				od="";
			}
			gsub(/[[:space:]]+$/, "", od);
			gsub(/[[:space:]]+$/, "", val);

			if( tag == "type" ) {
				type[o]=val;
			};
			if( tag == "choices" ) {
				choices[o]=val;
			};
			if( tag == "value" ) {
				value[o]=val;
			};
			if( tag == "description" ) {
				description[o]=val;
			};

		};
		printf("\n# Option: %s (%s)\n", o, type[o]);
		if (description[o] != "") { printf("#\tdescription: %s\n", description[o] ); };
		if (choices[o] != "") { printf("#\tchoices: %s\n", choices[o]); };
		if (value[o] != "") { printf("#\tvalue: %s\n", value[o]); }; 
		print_ebuild_iuse(type[o], o, choices[o], value[o]);
		print_ebuild_define_string(type[o], o, choices[o], value[o]);
	};
	printf("\nIUSE=\"${IUSE}%s\"\n", iuselist);

};
