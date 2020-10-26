use strict;
use warnings;
use Data::Dumper;
if(@ARGV<2)
{
	print "Usage perl <input> <dis>\n\n";
	exit;
}

open  B,"$ARGV[0]" or die "can not open $$ARGV[0]\n\n";
my @family;
my $dis=$ARGV[1];
#my %first;
#push @family,\%first;
my %score;
my %all_node;

while (my $line=<B>)
{
	chomp($line);
	my @info=split(/\s+/,$line);
	if(  $info[2]>=$dis &&( $info[0] ne $info[1]))
	{
  		my $novel1=$info[0];
  		my $novel2=$info[1];
  		#print $info[0],"\t",$info[1],"\n";
  		if(!exists $score{$novel1.":".$novel2})
 	 	  {
  		
				  		
  			 $score{$novel1.":".$novel2}=$info[2];
  	  	     $all_node{$novel1}=1;
  	    
  	  }
  }
}


#print Dumper(%score);

my %matri;
foreach my $a (sort  keys %all_node)
{
	foreach my $b(sort keys %all_node)
	 {
			if(exists $score{$a.":".$b})
		  {$matri{$a.":".$b}=$score{$a.":".$b};}
		  else
		  {$matri{$a.":".$b}=0;}
	 }
}

sub print_matri
{
	      my $ref_matri=shift;
	
print "node";
foreach my $a(sort keys %all_node)
{
	print "\t",$a;
}
print "\n";
foreach my $a (sort  keys %all_node)
{
	print $a,"\t";
	foreach my $b(sort keys %all_node)
	 {
		print $ref_matri->{$a.":".$b},"\t";
	 }
	 print "\n";
}
}
        
  # &print_matri(\%matri);
my @hash_keys=sort{$matri{$b} <=> $matri{$a}} keys %matri ;
my $largest_score=$matri{$hash_keys[0]};
 #print $largest_score,"\n";
while ($largest_score >=$dis)
{
	my $novel1=(split(/:/,$hash_keys[0]))[0];
	my $novel2=(split(/:/,$hash_keys[0]))[1];
	#print $hash_keys[0],"\n";
	#print $novel1,"\t",$novel2,"\t",$matri{$hash_keys[0]},"\n";
	delete $matri{$novel1.":".$novel2};
	delete $matri{$novel2.":".$novel1};
	delete $all_node{$novel1};
	delete $all_node{$novel2};	
	foreach my $item ( sort keys  %all_node)
	{ 
		
		#print $novel1,"\t",$item,"\n";
	  #print $novel2,"\t",$item,"\n";
		my $d1=$matri{$novel1.":".$item};
		#print "d1:\t",$d1,"\n";
	  my $d2=$matri{$novel2.":".$item};
		#print "d2\t",$d2,"\n";
	
		my $max_d;
		if($d1>$d2){$max_d=$d1;}else{$max_d=$d2;}
		$matri{$novel1."-".$novel2.":".$item}=$max_d;
		$matri{$item.":".$novel1."-".$novel2}=$max_d;
		delete $matri{$novel1.":".$item};
		delete $matri{$item.":".$novel1};
		delete $matri{$novel2.":".$item};
		delete $matri{$item.":".$novel2};
	}
	$matri{$novel1."-".$novel2.":".$novel1."-".$novel2}=0;
	$all_node{$novel1."-".$novel2}=1;
	
  #&print_matri(\%matri);
	my @key_num=keys %matri;
	if(@key_num>=2)
	{	#print  "matri num:::",scalar(@key_num),"\n";
		@hash_keys=sort{$matri{$b} <=> $matri{$a}} keys %matri ;
		$largest_score=$matri{$hash_keys[0]};
  }
 	else
 	{last;}
 #last;
}


foreach my $item (keys %all_node)
{ 
	my @nodes=split(/-/,$item);
	
	
		print "node link\t";
		foreach my $i (@nodes)
		{print $i,"\t";}
		print "\n";
	 
}



# open Table ,"$ARGV[0]"or die "can  not open file $ARGV[0]\n\n";
# my %items;
# open F_T, "$ARGV[1]" or die "can  not open $$ARGV[1]n\n";

#while (my $line=<Table>)
#{
# chomp($line);
# my $item_id=(split(/\s+/,$line))[0];


# $items{$item_id}=$line;

#}



#my $i=1;
#my %used;
#foreach my $item (%all_node)
#{
#	my @nodes=split(/-/,$item);
	#print "family_",$i,"\n";
#3	if(@nodes>=2)
#	{
#	foreach my $novel(@nodes)
#	{
#	   #print $novel,"\n";
#  	   my @info=split(/\s+/,$items{$novel});
# 	   print F_T $info[0],"\t","family_",$i,"\t";
#           print F_T  join("\t",@info[1..scalar(@info)-1]);
#	   print F_T "\n";
#	   #print $items{$novel},"\n";
#	   $used{$novel}=1;
#	}
#	$i++;
#      }
#}

#foreach my $item(keys %items)
#{
# if(!exists $used{$item})
#	{
#		#print "family_",$i,"\n";
#		my @info=split(/\s+/,$items{$item});
#		print F_T $info[0],"\t","-----\t";
#		print  F_T join("\t",@info[1..scalar(@info)-1]);
#		print F_T "\n";
#		#print $items{$item},"\n";
#		$i++;
#	}
#}
