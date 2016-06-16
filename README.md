# Sparrowdo

Simple configuration engine based on [sparrow](https://sparrowhub.org) plugin system.

# Build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo.svg)](https://travis-ci.org/melezhik/sparrowdo)

# Usage


    $ cat << EOF > sparrowfile

    use v6;
    
    use Sparrowdo;
    
    task_run  %(
      task => 'check disk available space',
      plugin => 'df-check',
      parameters => %( threshold => 80 )
    );
    
    task_run  %(
      task => 'install app',
      plugin => 'perl-app',
      parameters => %( 
        'app_source_url' => 'https://github.com/melezhik/web-app.git',
        'git_branch' => 'dev',
        'http_port' => 3030
      )
    );
    
    EOF


    $ sparrowdo --host=192.168.0.1

[![Sparrowdo screenshot](https://raw.githubusercontent.com/melezhik/sparrowdo/master/sparrowdo.png)](https://raw.githubusercontent.com/melezhik/sparrowdo/master/sparrowdo.png)

# Schema

      +-----------------+
      |                 |    ssh
      |                 |------------> < host-1 > 192.168.0.1
      | <master host>   |    ssh
      | {sparrowdo}     |------------------> < host-2 > 192.168.0.2
      |                 |    ssh 
      |                 |-----------------------> < host-N > 127.0.0.1
      |                 |
      +-----------------+


      +-------------+
      |             |
      | <host>      |
      |             |
      | {sparrow}   | 
      | {curl}      |
      |             |
      +-------------+

## Master host

Master host is the dedicated server where you push sparrow tasks execution on remote hosts.

Sparrowdo client should be installed at master host:

    $ panda install Sparrowdo

Sparrowdo acts over ssh installing sparrow [plugins](https://metacpan.org/pod/Sparrow#Plugins-API), applying configurations and running them as sparrow [tasks](https://metacpan.org/pod/Sparrow#Tasks-API).

A list of available sparrow plugins could be found here - [https://sparrowhub.org/search](https://sparrowhub.org/search).
Only [public](https://metacpan.org/pod/Sparrow#Public-plugins) sparrow plugins are supported for the current version of sparrowdo.


## Remote hosts

Remote hosts are configured by running sparrow client on them and executing sparrow tasks.

A Sparrow CPAN module, version >= 0.1.8 should be installed on remote hosts:

    $ cpanm Sparrow

A minimal none Perl dependencies also should be satisfied - `curl`, so sparrow could manage it's index files and
upload plugins. Eventually I will replace it by proper Perl module to reduce none Perl dependencies, but for now
it's not a big deal:

    $ yum install curl

# SSH setup

An assumption made that user you run `sparrowdo` under on master host has:

* ssh passwordless access to remote hosts
* sudo (passwordless?) rights on remote host

Eventually I will make user/ssh related stuff configurable so one could run sparrowdo with various ssh configurations and
users.

# Sparrowdo client command line parameters

## --help

Prints brief usage info.

## --http\_proxy

Sets http\_proxy environment variable on remote host.

## --https\_proxy

Sets https\_proxy environment variable on remote host.


## --verbose

Sets verbose mode ( low level information will be printed at console ).

## --skip\_index\_update

Do not call `sparrow index update` on remote host ( this command might be omitted if you want to speed up your deploys  as
this command could be time consuming ). See also [sparrow index update](https://metacpan.org/pod/Sparrow#Index-API) command reference.


# AUTHOR

[Aleksei Melezhik](mailto:melezhik@gmail.com)

# Home page

[https://github.com/melezhik/sparrowdo](https://github.com/melezhik/sparrowdo)

# Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# See also

* [Sparrow](https://metacpan.org/pod/Sparrow) - Multipurpose scenarios manager.

* [SparrowHub](https://sparrowhub.org) - Central repository of sparrow plugins.

* [Outthentic](https://metacpan.org/pod/Outthentic) - Multipurpose scenarios devkit.

# Thanks

To God as the One Who inspires me to do my job!

