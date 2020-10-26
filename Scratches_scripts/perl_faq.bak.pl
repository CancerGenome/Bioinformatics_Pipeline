#!/usr/bin/perl 
#===============================================================================
#
#        USAGE:  ./perl_faq.pl  
#
#  DESCRIPTION:  For perl description of NOTE of learning, read perl learning book
#
#       AUTHOR:  Wang yu , wangyu.big@gmail.com
#    INSTITUTE:  BIG.CAS
#      VERSION:  1.0
#      CREATED:  2009年09月01日 
#===============================================================================

chop: get rid of the last character
    uc(UPPER WORDS) uc(abc)=ABC
    rc(lower words)

print <<EOF
    blar blar
EOF

STRING Quote
    q, single quote
    qq quote double
    qr quote regex
    qw quote word
    qx quote execute outer script

ARRAY
    Definition: my @a = ((0)x10);
    pop and push #: delete last or add last to array
    shift and unshift #:delete first or add first to arry
    reverse @array
    sort @file (as default dictonary)  or sort {$a cmp $b}
    sort {$a<=>$b} as numerical   sort{$b<=>$a} # reverse as numerical
    sort {$hash{$b} <=> $hash{$a}} keys %hash;  # sort hash value not key
    map  use current array to get new array
        @numbers =qw(90 99)  @chr = map (chr$_,@numbers)  # changes number to chr format output Zc
    grep my @odd_number = grep {$_ % 2}1..1000;
         my @matching = grep {/\bfred\b/i} <FILE>;
         my @matching = grep /\bfred\b/i ,<FILE>;
    scalar : #return number of array
    delete exists splice(@,start,length)
    undef : undefined @
    use Array::Compare; # sort two array
        my @1,@2;
        my $compare_result = Array::Compare->new;
        if ($compare_result->compare(\@1,\@2));
    Slice:
    var:    my ($chr,$pos,undef,undef,undef)= split/\s+/;
            or my ($chr,$pos)= (split/\s+/)[1,5];  # this is more effcient
    array:    my @new = @old[1,2,3,4,5]
            print @old[1,2,3,4,5],"\n";
    hash:    my @three = ($score["a"],$score["b"],$score["c"]);
            Equal to my @three = @score {qw/a b c/}   #{} indicate here is hash
            Another useful way is @query =qw(a b c)  @three= @score{@query}
            my @hasharray;
            $hasharray[1]->{keys} ++;
            get hash use my %hash = $hasharray[1];
    sanxuan my $null = (exists $qua{$_})? ($qua{$_}++) : ($qua{$_}=1);

HASH
    keys values delete exists
    each # while ($key,$value)= each(%hash)
    my %hash=('a' => 1,'g' => 2,'y' => 3,'r' => 4,'b' => 2);
    defined multiple hash;
        for (1..10){
            my $h = $hash{1};
            my $h2 = $h->{2} # memory exhaust
        }

Complex Data Structure
Two dimension array: $foo[$row][$col] = 'w';
Two dimension hash: $foo{$row}{$col} = 'w';
Hash of Array : $foo{'night'}[1] = 'March' , equals to @cache = @{$foo{'night'}} ; $cache[0] = 'March'
Array of Hash: $foo['$i']{'name'} = 'Joe' , equals to %hash = %{$foo['$i']} 
Good Printing: $a[$i] = [@list] ,equals to @{$a[$i]} = @list

Cross link
    $$a : for variable
    @$a or $a->3 : for array 
    %$h or $h->{"key"} or my @new = @$rh{"key1","key2"}
    $rs = \&foo;         &$rs();       # for function
    ref fuction return reference type : print ref($ref)

Multi-Array
     $abc=[["00","01"],["a","b"]]
     for use: $var =  $abc -> [1][1]

Use Constant    
    use constant PI => 4*atan2(1,1)
    use constant WEEK => qw(sunday,...)   USE: (WEEK)[1]
    use constant WEEK => {
        Monday => 'mon',
        Tuesday => 'mon',
    }        %abbr= WEEK;$day='Monday';print $abbr{$day}

ARROW
    same with $pre[$x][$y][$z] <=>  $pre[x] -> [y] -> [z]
    use in objects: $object -> method (@arguments)

Control flow 
    switch($val){
    case 1 {print "2"}
    case "a" {print "string"}
    case [1..20,30]
    case (@array)
    case qr/\w+/
    case (%hash)
    case (\%hash)
    case (\&hash)
}

File control
    rename ("origin","rename")
    mkdir ("new_file",0777)
    rmdir ("new_file")

System command
    system()
    ``
    my $cmd = 'c:\windows\notepad.exe'
    my $args ='notepad.exe c:\windws\notepad.exe'
    my $pid =0;
    Win32:Spwan    ($cmd,$args,$pid);

telnet module:
    use Net:Telnet()
    $t -> new Net:Telnet(Timeout=> 10,Prompt => '/bash\$ $/')
    $t->open ("sparky")
    $t->login ($usename,$passwd)
    @lines = $t->cmd("who")
    print @lines

More regrex rules see think in perl and my perl book
    print /(\d+)/ "$1" ; # print match case
	match variable: my $a = 'GA', my $b='A', if($a =~ /\Q$b/){}
    @array =m/([0-9]+[MIDNSHP])/g; # match multi at once
    print fa : while($seq =~ /([AGCTN]{1,60})/ig) {print $1,"\n";}
    Get howmany site match this
    my $target ='123*a1a123.d';
    my $query ='123';
    *? not greedy
    some option of modifiers: 
        ///i : case-insensitive
        ///s : if use .* , this match newline (\n) also, not only character.
        ///x : allow adding arbitary whitespace or newline for a pattern, easily read 
        word anchor: \b set work start or end \ba match a* a\b match *a
                     \B do not end word, a\B match ab* or .. , but does not match a .
    while($target=~m/$query/g){
                printf "%d\n",$-[0];  # attention imoportant
    }
    example : $` $& $' will return string before matching , matching , after matching


Print format
    < left > right | middle '#' right for number
    
Module
    use Module; use Module LIST;
    perl -I @INC
    usb lib '/home/lib/*'
    BEGIN{unshift @INC,'/home/lib/*';}

Get option:
    use Getopt:Std;
    my $opt= 'hdvf:s';  
    getopts("$opt",\my %pot)  #opt store in pot hash

Perlrun line command:
    -a autosplit same with split;
    -c check syntax
    -e command line
    -i use as backup afterfix/ like sed -i, perl -i.old
    -n assume loop
    -w warning

Standard Perl libaray
    See Perl_quick_func_ref.pdf P36

Filehandle
    select HANDLE to change default handle, print "something" to HANDLE you select;


File test   Meaning
    -r  File or directory is readable by this (effective) user or group
    -w  File or directory is writable by this (effective) user or group
    -x  File or directory is executable by this (effective) user or group
    -o  File or directory is owned by this (effective) user
    -R  File or directory is readable by this real user or group
    -W  File or directory is writable by this real user or group
    -X  File or directory is executable by this real user or group
    -O  File or directory is owned by this real user
    -e  File or directory name exists
    -z  File exists and has zero size (always false for directories)
    -s  File or directory exists and has nonzero size (the value is the size in bytes)
    -f  Entry is a plain file
    -d  Entry is a directory
    -l  Entry is a symbolic link
    -S  Entry is a socket

File Test Operators

File test   Meaning
    -p  Entry is a named pipe (a “fifo”)
    -b  Entry is a block-special file (like a mountable disk)
    -c  Entry is a character-special file (like an I/O device)
    -u  File or directory is setuid
    -g  File or directory is setgid
    -k  File or directory has the sticky bit set
    -t  The filehandle is a TTY (as reported by theisatty()system function; filenames can’t be tested by this test)
    -T  File looks like a “text” file
    -B  File looks like a “binary” file
    -M  Modification age (measured in days)
    -A  Access age (measured in days)
    -C  Inode-modification age (measured in days) 

    From Xiaoluotuo
Given When - like switch
EVAL for check errors
~~ : higher ~

Used in Perl : Piep Example:
$reference="/share/disk7-3/wuzhygroup/wangy/db/human/hg18.fa";
$normal_bam="HCC13-N0";
$tumor_bam="HCC13-T1";
$normal_pileup="samtools pileup -f $reference $normal_bam";
$tumor_pileup="samtools pileup -f $reference $tumor_bam";
#`head -10 <\($normal_pileup\)`;
`bash -c \"VarScan somatic <\($normal_pileup\) <\($tumor_pileup\) HCC13-T1.test\"`;

Case Sample:
Print 50 lines merge each time
perl -ane 'if($F[0] ne $last){print "$last\t$lastp\t$a\t$b\n";$i=1;$a=$F[5];$b=$F[6];} else {if($i%10==0){print "$last\t$lastp\t$a\t$b\t$i\n";$a=0;$b=0;} $a+=$F[5];$b+=$F[6];$i++;} $last= $F[0];$lastp=$F[1];'

Sliding window = 1/10 of total window
perl -ane 'if($F[0] ne $last){print "$last\t$lastp\t$a\t$b\n";$i=1;$a=$F[5];$b=$F[6];} else {if($i%10==0){print "$last\t$lastp\t$a\t$b\t$i\n";$a=$lasta;$b=$lastb;$i++} $a+=$F[5];$b+=$F[6];$i++;} $last= $F[0];$lastp=$F[1];$lasta=$F[5];$lastb=$F[6];'

Option Get
use Getopt::Std;
our ($opt_i,$opt_h);
getopts("i:h"); # thus can get argument for i and boolen for h

perl -nE' BEGIN{ ($/, $") = ("CDS", "\t") } say "@r[0,1]" if @r= m!/(?:locus_tag|product)="(.+?)"!g and @r>1 ' file

Perl Internal Special Variable:
Special Vars Quick Reference

$_	The default or implicit variable.
@_	Subroutine parameters.
$a
$b	sort comparison routine variables.
@ARGV	The command-line args.
Regular Expressions
$<digit>	Regexp parenthetical capture holders.
$&	Last successful match (degrades performance).
${^MATCH}	Similar to $& without performance penalty. Requires /p modifier.
$`	Prematch for last successful match string (degrades performance).
${^PREMATCH}	Similar to $` without performance penalty. Requires /p modifier.
$'	Postmatch for last successful match string (degrades performance).
${^POSTMATCH}	Similar to $' without performance penalty. Requires /p modifier.
$+	Last paren match.
$^N	Last closed paren match (last submatch).
@+	Offsets of ends of successful submatches in scope.
@-	Offsets of starts of successful submatches in scope.
%+	Like @+, but for named submatches.
%-	Like @-, but for named submatches.
$^R	Last regexp (?{code}) result.
${^RE_DEBUG_FLAGS}	Current value of regexp debugging flags. See use re 'debug';
${^RE_TRIE_MAXBUF}	Control memory allocations for RE optimizations for large alternations.
Encoding
${^ENCODING}	The object reference to the Encode object, used to convert the source code to Unicode.
${^OPEN}	Internal use: \0 separated Input / Output layer information.
${^UNICODE}	Read-only Unicode settings.
${^UTF8CACHE}	State of the internal UTF-8 offset caching code.
${^UTF8LOCALE}	Indicates whether UTF8 locale was detected at startup.
IO and Separators
$.	Current line number (or record number) of most recent filehandle.
$/	Input record separator.
$|	Output autoflush. 1=autoflush, 0=default. Applies to currently selected handle.
$,	Output field separator (lists)
$\	Output record separator.
$"	Output list separator. (interpolated lists)
$;	Subscript separator. (Use a real multidimensional array instead.)
Formats
$%	Page number for currently selected output channel.
$=	Current page length.
$-	Number of lines left on page.
$~	Format name.
$^	Name of top-of-page format.
$:	Format line break characters
$^L	Form feed (default "\f").
$^A	Format Accumulator
Status Reporting
$?	Child error. Status code of most recent system call or pipe.
$!	Operating System Error. (What just went 'bang'?)
%!	Error number hash
$^E	Extended Operating System Error (Extra error explanation).
$@	Eval error.
${^CHILD_ERROR_NATIVE}	Native status returned by the last pipe close, backtick (`` ) command, successful call to wait() or waitpid(), or from the system() operator.
ID's and Process Information
$$	Process ID
$<	Real user id of process.
$>	Effective user id of process.
$(	Real group id of process.
$)	Effective group id of process.
$0	Program name.
$^O	Operating System name.
Perl Status Info
$]	Old: Version and patch number of perl interpreter. Deprecated.
$^C	Current value of flag associated with -c switch.
$^D	Current value of debugging flags
$^F	Maximum system file descriptor.
$^I	Value of the -i (inplace edit) switch.
$^M	Emergency Memory pool.
$^P	Internal variable for debugging support.
$^R	Last regexp (?{code}) result.
$^S	Exceptions being caught. (eval)
$^T	Base time of program start.
$^V	Perl version.
$^W	Status of -w switch
${^WARNING_BITS}	Current set of warning checks enabled by use warnings;
$^X	Perl executable name.
${^GLOBAL_PHASE}	Current phase of the Perl interpreter.
$^H	Internal use only: Hook into Lexical Scoping.
%^H	Internaluse only: Useful to implement scoped pragmas.
${^TAINT}	Taint mode read-only flag.
${^WIN32_SLOPPY_STAT}	If true on Windows stat() won't try to open the file.
Command Line Args
ARGV	Filehandle iterates over files from command line (see also <>).
$ARGV	Name of current file when reading <>
@ARGV	List of command line args.
ARGVOUT	Output filehandle for -i switch
Miscellaneous
@F	Autosplit (-a mode) recipient.
@INC	List of library paths.
%INC	Keys are filenames, values are paths to modules included via use, require, or do.
%ENV	Hash containing current environment variables
%SIG	Signal handlers.
$[	Array and substr first element (Deprecated!)

# remove tped file 
perl -ane '{my %hash; for my $i(4..$#F){$hash{$F[$i]} = 1;} if($hash{'A'} + $hash{'C'} + $hash{'G'} + $hash{'T'}<3  ) {print $_}  }'
