#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
use SVG;
use Font;
my $wid = 1380;
my $svg = SVG->new('width',$wid,'height',1024);
#my $g1 = $svg->group("transform"=>"translate(10,10)");
#my $wid = textWidth("ArialNarrow",0.05,"good hhhhhhhh");
#my $hig = textHeight(0.05);

#basic notes
$svg->title('id','document-title','-cdata','This is the title');
$svg->desc('id','document-desc', '-cdata','This is a description');
$svg->comment('comment 1','comment 2','comment 3');

#input data
# parameters

	# draw full line
	$svg->line('x1',200,'y1',0,'x2',200,'y2',$wid-200,'stroke','blue','stroke-width',25);
	$svg->text('x',20,'y',390,'stroke','blue','fill','blue','-cdata',"chr",'stroke-width',0);
	for my $i (1..int(2000000/($wid-200))){
				
	}
open IN, "$ARGV[0]";
while(<IN>){

	chomp;
	my ($chr,$lp,$match_type,$rp,$size) = split/\s+/,[2,3,5,7,8];
	$size = abs($size);

}
print $svg->xmlify();
=pod

$svg->text('x',20,'y',$y1,'stroke','blue','fill','blue','-cdata',"$last_chr",'stroke-width',0);
#$svg->circle('cx',20,'cy',20,'r',10,'stroke','red','fill','green');
#$svg->ellipse('cx',60,'cy',20,'rx',10,'ry',5,'stroke','red','fill','green');
#print " $_\t$last_chr\t$chr\t$x1\t$x2\t$y1\t$y2\t$red\t$green\n";
#print "<line stroke=\"rgb($red,$green,0)\" stroke-width=\"4\" x1=\"$x1\" x2=\"$x2\" y1=\"$y1\" y2=\"$y1\" /> \n";
$svg->line('x1',$x1,'y1',$y1,'x2',$x2,'y2',$y1,'stroke',"rgb($red,$green,0)",'stroke-width',25);
#$svg->rect('x',120, 'y',20,'width',40,'height',50,'stroke','red','fill','green');
#$svg->polygon('points',[300,0,400,0,350,50],'fill','red','stroke','green');
#$svg->tag('circle', 'cx',300,'cy',40,'r',20,'stroke','red','fill','green');
}
$svg->text('x',20,'y',$y1,'stroke','blue','fill','blue','-cdata',"$last_chr",'stroke-width',0);

=head
#  size_mark
$svg->line('x1',$x1+200,'y1',$y1+50,'x2',$x1+200+$length*2,'y2',$y1+50,'stroke',"rgb(0,255,0)",'stroke-width',6);
$svg->text('x',$x1+180+$length*2,'y',$y1+30,'stroke','blue','fill','blue','-cdata',"10K",'stroke-width',0);
#   color_mark
my @print =(0,25,50,75,100,125,150,175,200,225,255);
my $new_x1 = $x1+300;
my $new_y1 = $y1+50;
my $wide =5;
foreach( @print){
my $num = 255 - $_;
$svg->line('x1',$new_x1,'y1',$new_y1,'x2',$new_x1+$wide,'y2',$new_y1,'stroke',"rgb(0,$num,0)",'stroke-width',5);
$new_x1 += $wide;
}
foreach(@print){
my $num = $_;
$svg->line('x1',$new_x1,'y1',$new_y1,'x2',$new_x1+$wide,'y2',$new_y1,'stroke',"rgb($num,0,0)",'stroke-width',5);
$new_x1 +=$wide;
}
$svg->text('x',$new_x1-115,'y',$new_y1-20,'stroke','blue','fill','blue','-cdata',"1",'stroke-width',0);
$svg->text('x',$new_x1-10,'y',$new_y1-20,'stroke','blue','fill','blue','-cdata',"130",'stroke-width',0);

#indicates the hyperlink and defines where the link goes
#my $anch = $svg->anchor(
#         -href=>'http://www.google.com/',
#    );
#$anch->circle(cx=>100,cy=>300,r=>50,'fill','red');




###how to use group, and transform
###默认"transform"=>"translate(0,0) scale(1) rotate(0)"
### 指定中心的旋转：rotate(角度，中心x坐标，中心y坐标)
#
#$svg->line('x1',0,'y1',240,'x2',640,'y2',240,'stroke','red','stroke-width',3);
#$svg->line('x1',320,'y1',0,'x2',320,'y2',480,'stroke','red','stroke-width',3);
#
#my $wid = textWidth("ArialNarrow",12,"good hhhhhhhh");
#my $hig = textHeight(12);
#$wid /= 2;
#$hig /= 2;
#$hig = -$hig;
#
#my $g1 = $svg->group("transform"=>"translate(320,240)");
#$g1->text('x',0,'y',0,'-cdata',"good hhhhhhhh","stroke","blue","transform"=>"rotate(0,$wid,$hig)");
#$g1->text('x',0,'y',0,'-cdata',"good hhhhhhhh","stroke","blue","transform"=>"rotate(45,$wid,$hig)");
#$g1->text('x',0,'y',0,'-cdata',"good hhhhhhhh","stroke","blue","transform"=>"rotate(90,$wid,$hig)");
#$g1->text('x',0,'y',0,'-cdata',"good hhhhhhhh","stroke","blue","transform"=>"rotate(135,$wid,$hig)");
#
#
#
###how to use script
#my $st1 = $svg->script();
#$st1->CDATA(
#	qq(
#		function showmsg()
#		{
#			alert("good mood");
#		}
#	)
#);
#$svg->text('x',0,'y',400,'-cdata',"good mood","stroke","blue",'onclick','showmsg()');
#
###how to use style,注意：style和gradient相互影响，不能同时使用
##my $stl = $svg->style(type=>"text/css");
##$stl->CDATA(
##	qq(
##		rect {stroke:black; fill:yellow}
##		rect.differe {stroke:red; fill:none}
##		rect.fanw {stroke:green; fill:olive}
##	)
##);
##$svg->rect('x',10, 'y',120,'width',40,'height',50);
##$svg->rect('class','differe','x',10, 'y',220,'width',40,'height',50);
##$svg->rect('class','fanw','x',10, 'y',320,'width',40,'height',50);
##
#
##how to use color linear gradient，style和gradient相互影响，不能同时使用
#my $x = 400;
#my $y = 400;
#my $gradient = $svg->gradient(
#	-type => "linear",
#	id    => "gradient_1",
#	gradientUnits => "userSpaceOnUse",
#	x1	=>	$x,
#	x2	=>	$x+60,
#	
#);
#$gradient->stop('offset'=>0,style=>"stop-color:#FFFF00");
#$gradient->stop('offset'=>0.5,style=>"stop-color:#FF0000");
#$gradient->stop('offset'=>1,style=>"stop-color:#000000");
#$svg->rect('x',$x, 'y',$y,'width',60,'height',40,'fill','url(#gradient_1)');
#
##how to use color radial gradient
#my $gra1 = $svg->gradient(
#        -type => "radial",
#        id    => "gradient_2",
#		gradientUnits => "userSpaceOnUse",
#		cx	=>	300,
#		cy	=>	400,
#		r	=>	40,
#    );
#$gra1->stop('offset'=>0,style=>"stop-color:green");
#$gra1->stop('offset'=>1,style=>"stop-color:red");
#$svg->circle('cx',300,'cy',400,'r',40,'fill','url(#gradient_2)');
#


##  按路径剪切,以及交互动作
##先制造剪切路径：
#my $clip = $svg->tag('clipPath','id','myClip');
#$clip->circle('cx',500,'cy',300,'r',100);
##在对象中添加clip-path属性：
#$svg->rect('fill','red','x',250,'y',250,'width',800,'height',100,'clip-path','url(#myClip)','onclick',"alert('x:0\ny:0')",'onmousemove',"window.status='x:0\thello world good happy'");

## 弹出提示窗口：onclick="alert('x:0\ny:0')" 
## 在状态栏显示提示信息：onmousemove="window.status='x:0\ty:0'"


## draw path 
#M Establish origin at point specified
#L Straight line path from current position to point specified
#H Horizontal line path from current position to point specified
#V Vertical line path from current position to pointspecified
#Z Straight line back to original
#$svg->path('d',['M',0, 0, 'L',100, 0, 'L',50, 100,'Z'],'fill','red','stroke','green');
#
### draw cubic bezier curve [M mx,my C c1x,c1y c2x,c2y x,y]
#$svg->path('d',['M',100,100,'C',120,10,180,50,200,100],'fill','none','stroke','green');

