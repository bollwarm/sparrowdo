use v6;

unit module Sparrowdo;

use Terminal::ANSIColor;

use JSON::Tiny;

my $cleanup_state =  False;
my $index_update =  False;

sub task_run(%args) is export { 

  say colored('running task <' ~ %args<task> ~ '> plg <' ~ %args<plugin> ~ '> ', 'bold green on_blue');

  say 'parameters: ' , %args<parameters>;

  if $index_update == False and ! $Sparrowdo::SkipIndexUpdate  {
    ssh_shell $Sparrowdo::Verbose ?? 'sparrow index update' !! 'sparrow index update 1>/dev/null';
    $index_update = True;
  }


  if $cleanup_state == False  {
    ssh_shell $Sparrowdo::Verbose ?? 'sparrow project remove sparrowdo' !! 'sparrow project remove sparrowdo 1>/dev/null';
    $cleanup_state = True;
  }

  ssh_shell $Sparrowdo::Verbose ?? 'sparrow plg install ' ~ %args<plugin> !! 'sparrow plg install ' ~ %args<plugin> ~ ' 1>/dev/null';

  ssh_shell $Sparrowdo::Verbose ?? 'sparrow project create sparrowdo' !! 'sparrow project create sparrowdo 1>/dev/null';

  my $sparrow_task = %args<task>.subst(/\s+/,'_', :g);

  ssh_shell  $Sparrowdo::Verbose ?? 'sparrow task add sparrowdo ' ~ $sparrow_task ~ ' ' ~ %args<plugin> !! 
  'sparrow task add sparrowdo ' ~ $sparrow_task ~ ' ' ~ %args<plugin> ~ ' 1>/dev/null';

  my $filename = '/tmp/' ~ $sparrow_task ~ '.json';
  
  my $fh = open $filename, :w;

  $fh.say(to-json %args<parameters>);

  $fh.close;

  scp $filename;

  ssh_shell 'sparrow task run sparrowdo ' ~ $sparrow_task ~ ' --json ' ~ $filename;


}
 

sub ssh_shell ( $cmd ) {


  my @bash_commands = ( 'export LC_ALL=en_US.UTF-8' );

  @bash_commands.push:  'export http_proxy=' ~ $Sparrowdo::HttpProxy if $Sparrowdo::HttpProxy;
  @bash_commands.push:  'export https_proxy=' ~ $Sparrowdo::HttpsProxy if $Sparrowdo::HttpsProxy;
  @bash_commands.push:  $cmd;

  my $ssh_host_term = $Sparrowdo::Host;

  $ssh_host_term = $Sparrowdo::SshUser ~ '@' ~ $ssh_host_term if $Sparrowdo::SshUser;

  my $ssh_cmd = 'ssh -q -tt -p ' ~ $Sparrowdo::SshPort ~ ' ' ~ $ssh_host_term ~ " ' sudo bash -c \"" ~ ( join ' ; ', @bash_commands ) ~ "\"'";
  
  say colored($ssh_cmd, 'bold green') if $Sparrowdo::Verbose;

  shell $ssh_cmd;

}

sub scp ( $file ) {

  my $ssh_host_term = $Sparrowdo::Host;

  $ssh_host_term = $Sparrowdo::SshUser ~ '@' ~ $ssh_host_term if $Sparrowdo::SshUser;

  my $scp_params = '-P' ~ $Sparrowdo::SshPort;

  $scp_params ~= ' -q'  unless $Sparrowdo::Verbose;
  
  shell 'scp '~ $scp_params ~ ' ' ~ $file ~ ' ' ~ $ssh_host_term ~ ':/tmp/';

}

