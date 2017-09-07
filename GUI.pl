#!/usr/bin/env perl;
#coding by Yu-Cheng Liu
#email lyc760214@hotmail.com

#loading module
use strict;
use Net::MySQL;
use Tk;

require Tk::DialogBox;
require Tk::LabEntry;



#prepare some variables
my $mysql;


#initialize main window
my $mw = MainWindow->new;
$mw->title('MySQL API Demo');
$mw->resizable(0,0);



#defined a login window
my ($username, $password);
my $login = $mw->DialogBox(-title => 'Login', -buttons => ['Login', 'Cancel'],
		-default_button => 'Login');

#add two entries for username and password in the login window
$login->add('LabEntry', -textvariable => \$username, -width => 20,
		-label => 'USERNAME', -labelPack => [-side => 'left'])->pack;
$login->add('LabEntry', -textvariable => \$password, -width => 20, -show => '*',
		-label => 'PASSWORD', -labelPack => [-side => 'left'])->pack;



#defined first frame for text and scroll bars
my $frame1 = $mw->Frame()->pack(-side => 'top', -fill => 'both', -expand => 1);

#defined a text and two scroll bars
my $xscroll = $frame1->Scrollbar(-orient => 'horizontal');
my $yscroll = $frame1->Scrollbar();
my $text = $frame1->Text(-font => 'Time 10', -width => 60, -height => 6,
		-xscrollcommand => ['set', $xscroll],
		-yscrollcommand => ['set', $yscroll]);
$xscroll->configure(-command => ['xview', $text]);
$yscroll->configure(-command => ['yview', $text]);

#presentation of the text and scroll bars
$xscroll->pack(-side => 'bottom', -fill => 'x', -expand => 1);
$yscroll->pack(-side => 'right', -fill => 'y', -expand => 1);
$text->pack(-side => 'bottom', -fill => 'both', -expand => 1);



#difined second frame for file brower
my $frame2 = $mw->Frame()->pack(-side => 'top', -fill => 'x', -expand => 1);

#defined file label, entry and brower
my $label = $frame2->Label(-text => 'SELECT');
my $entry = $frame2->Entry(-width => 40);
my $brower_b = $frame2->Button(-text => 'BROWER', -height => 1, -width => 10, -command => \&brower_do);

#presentation of the file, label and brower
$label->pack(-side => 'left');
$entry->pack(-side => 'left', -fill => 'x', -expand => 1);
$brower_b->pack(-side => 'left');


#difined third frame for submit and exit buttons
my $frame3 = $mw->Frame()->pack(-side => 'top', -fill => 'x', -expand => 1);

#define submit and exit
my $submit_b = $frame3->Button(-text => 'SUBMIT', -height => 1, -width => 10, -state => 'disabled',
		-command => \&submit_do);
my $exit_b = $frame3->Button(-text => 'EXIT', -height => 1, -width => 10, -command => \&exit_do);

#presentation of the submit and exit buttons
$exit_b->pack(-side => 'right');
$submit_b->pack(-side => 'right');


#Login DB
if($login->Show() eq 'Login'){
	$mysql = Net::MySQL->new(
		hostname => 'localhost',
		database => 'test',
		user => $username,
		password => $password
	);
}

$text->insert('end', "Welcom to the DB API demo.\n***************************\n");


MainLoop;

#command functions
sub brower_do {
	my $file = $mw->getOpenFile();
	if(defined $file and ($file ne '')){
		$entry->delete(0, 'end');
		$entry->insert(0, $file);
		$entry->xview('end');
		$submit_b->configure(-state => 'normal');
	}
}

sub submit_do {
	$text->insert('end', "You upload ".$entry->get()." to localhost.\n");
	open INF, $entry->get();
	my $lines;
	while(my $line=<INF>){
		my @word=split(/\s+/, $line);
		$lines .= "(\'".join("\',\'", @word)."\'),";
	}
	$lines =~ s/\,$//;
	$mysql->query(qq{
		INSERT INTO example_table (name, email, phone) VALUES $lines
	});
	$text->insert('end', sprintf("Affected row: %d\n", $mysql->get_affected_rows_length));
	$text->insert('end', $mysql->get_error_message."\n") if $mysql->is_error;
	$text->insert('end', "Upload finish!!\n***************************\n\n");
	$text->yview('end');
	$entry->delete(0, 'end');
	$submit_b->configure(-state => 'disabled');
}

sub exit_do {
	my $yesno_b = $mw->messageBox(-title => 'Exit?', -message => 'Are you sure?',
			-type => 'yesno', -icon => 'question');
	if($yesno_b eq "Yes"){
		exit;
	}
}
