#!/usr/bin/perl -w
my $compute=`pbsnodes |grep "^[a-y]"`;
my @nodes=split(/\n/,$compute);
my %quehash=("asmque" => "asmque", "genomics" => "genomics", "bioque" => "bioque", "dataque" => "dataque", "fat03que" => "fat03que"); 
print "QUEUE***NODES****STATE****CPU****JOBS\n\n";
foreach (@nodes){
my $info_line=`pbsnodes -q $_`;
@node_info=split(/\n/,$info_line);
$node_info[0]=~ s/^\s+//g;
$node_info[1]=~ s/^\s+//g;
$node_info[1]=~ s/^(state = )//g;
$node_info[2]=~ s/^\s+//g;
$node_info[2]=~ s/\s//g;
$node_info[3]=~ s/^\s+//g;
if ($node_info[3]=~ /^(properties)/){
$node_info[3]=~ s/^(properties = )//g;
$queue=$quehash{$node_info[3]};
}
$node_info[5]=~ s/^\s+//g;
if ($node_info[5]=~/^(jobs)/){
 $node_info[5]=~ s/\.ibmu01//g;
 $node_info[5]=~s/ //g;
 $coljobs=$node_info[5];
}else{
  $coljobs="jobs=NULL";
}
print "$queue****$node_info[0]****$node_info[1]****$node_info[2]****$coljobs \n";
}
