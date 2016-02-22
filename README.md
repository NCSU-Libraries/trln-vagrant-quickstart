# TRLN Blacklight Provision Quickstart

This project contains the setup for a
[vagrant](https://www.vagrantup.com/)-based box for the [TRLN Blacklight
Quickstart](https://github.com/NCSU-Libraries/trln-blacklight-quickstart)
application.  It uses [puppet](https://puppetlabs.com) as the primary
provisioning mechanism.  

## Usage

Install vagrant and puppet on your host.  Everything was developed with the Virtualbox provider, so probably you'll want to have that available.

```
./go
```

or

```
cd scripts; ./quickstart.sh; cd ..; vagrant up --provider=virtualbox
```

Will install some required puppet modules and download some files that will be built into packages on the guest VM.  

```
vagrant up
```

installs and provisions the virtual machine, does a `git clone` of the
blacklight quickstart, and runs its installation script.  The result will be a ready-to-go Blacklight installation in `/home/vagrant/projects/trln-blacklight-quickstart` (see that project's documentation for information about how to work with it).  One of the steps is compiling the latest Ruby, so be warned that it can actually take a while.  You will probably see a significant pause after the line

```Notice: /Stage[main]/Chruby/Exec[install ruby-install]/returns: execute successfully``` 

is output by the process.  This is where `ruby-install` is compiling a fresh
version of Ruby for the VM (see below for why).

For convenience, the cloned git repository will also be available in
`projects/trln-blacklight-quickstart` so you can use the git configuration of
your host system and edit the files in the Rails project using the tools
available on your host system.  

To log into your Vagrant machine, simply type 

```vagrant ssh``` at the shell (assumes your working directory is the one containing this file and `Vagrantfile`)

If everything worked and you've created an index and started rails (`bundle exec rails s` from the project directory on the guest)

Blacklight can be accessed via a browser in the *host* via [http://localhost:8088]; Solr will be available via [http://localhost:8983/solr] (from either the guest *or* the host).

The Vagrantfile forwards port 3000 on the guest to 8088 on the host, and 8983
on the guest to 8983 on the host. 


## FAQ

1. **It got nearly to the end and "Initialize quickstart application" failed!**

    Running the `init.sh` script is the very last step in provisioning the machine, but it encompasses a number of tasks.  One which I can't make completely reliable involves downloading, verifying, and unpacking Solr. You can tell this is the problem if something like

    ``` 
    Checksum of downloaded file /tmp/solr-5.4.1.tgz does not match
    ``` 

    shows up in the output of the `vagrant up` command.  If that happens, it's easy to fix: 

    ```
    $ vagrant ssh
    # now connected to the VM
    $ cd projects/trln-blacklight-quickstart
    $ rm /tmp/solr-\*.tgz
    $ bundle exec rake trln:solr:install
    ```

    And your download will start again.  If it fails (again?!) you could try again and run it on the host machine (`cd projects/trln-blacklight-quickstart`) ... it should work.

    And your download will start again.

2. **What if I don't want to use Vagrant?**

    You can start with a traditional server, or your own workstation, and just 

    ```git clone https://github.com/NCSU-Libraries/trln-blacklight-quickstart.git```

    onto the machine and probably be perfectly happy.  You might need to track down a few dependencies, though. 

3. **What's up with `chruby` and `ruby-install`?**

    These are complicated pieces of the puzzle, and the need to compile them (or, more properly,
    the Ruby version installed by `ruby-install` increases the initial install time.  One of the issues is that there are
    different implementations of Ruby, and one of them (MRI) is better for running
    Rails / Blacklight, while the other (JRuby) is better for running the indexing
    process, and we're testing both.  So the install process creates a VM where
    it's easy to switch between these implementations quickly. 

4. **Why Not Just Provide a (preconfigured) Vagrant Box**?

    We could do that!  We *should* do that (maybe)!  
    
    In fact it's a better idea than what this does since we could avoid all the package installation and compilation at the start and reduce the amount of time it takes to get going. 

    However, doing that right means having more infrastructure in place than I want to
    assume.  We avoid having to store large binaries in the repository (for now).
    Vagrant is also not necessarily the technology we will end up going with.

    In part this is a learning and demonstration exercise.  It's
    not intended for production use.  In particular I will not present the puppet
    module definition of the right way to do things; it is in part an artifact of
    not having a configuration management infrastructure that can support such a
    project.

All code is provided under a GPL v3 license, and is copyright North Carolina
State University 2016.
