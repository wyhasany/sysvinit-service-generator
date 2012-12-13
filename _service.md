# Sample service script for debianoids

Look at [LSB init scripts](http://wiki.debian.org/LSBInitScripts) for more information.

## Usage

Copy to `/etc/init.d`:

```sh
# replace "$YOUR_SERVICE_NAME" with your service's name (whenever it's not enough obvious)
cp "service.sh" "/etc/init.d/$YOUR_SERVICE_NAME"
chmod +x /etc/init.d/$YOUR_SERVICE_NAME
```

Edit the script and replace following tokens:

* `<NAME>` = `$YOUR_SERVICE_NAME`
* `<DESCRIPTION>` = Describe your service here (be concise)
* Feel free to modify the LSB header, I've made default choices you may not agree with
* `<COMMAND>` = Command to start your server (for example `/home/myuser/.dropbox-dist/dropboxd`)
* `<USER>` = Login of the system user the script should be run as (for example `myuser`)

Start and test your service:

```sh
service $YOUR_SERVICE_NAME start
service $YOUR_SERVICE_NAME stop
```

Install service to be run at boot-time:

```sh
update-rc.d $YOUR_SERVICE_NAME defaults
```

Enjoy

## Uninstall

The service can uninstall itself with `service $NAME uninstall`. Yes, that's very easy, therefore a bit dangerous. But as it's an auto-generated script, you can bring it back very easily. I use it for tests and often install/uninstall, that's why I've put that here.

Don't want it? Remove lines 56-58 of the service's script.

## Logs?

Your service will log its output to `/var/log/$NAME.log`. Don't forget to setup a logrotate :)

## I'm noob and/or lazy

Yep, I'm lazy too. But still, I've written a script to automate this :)

```sh
wget 'https://raw.github.com/gist/4275302/new-service.sh' && bash new-service.sh
```

In this script I will download `service.sh` into a `tempfile`, replace some tokens, and then show you commands you should run as superuser.

If you feel confident enough with my script, you can `sudo` the script directly:

```sh
wget 'https://raw.github.com/gist/4275302/new-service.sh' && sudo bash new-service.sh
```

Note: the cool hipsterish `curl $URL | bash` won't work here, I don't really want to check why.

### Demo

Creating the service:

![service-create](http://dl.dropbox.com/u/6414656/gist-4275302/service-create.png)

Looking at service files (logs, pid):

![service-files](http://dl.dropbox.com/u/6414656/gist-4275302/service-files.png)

Uninstalling service:

![service-uninstall](http://dl.dropbox.com/u/6414656/gist-4275302/service-uninstall.png)
