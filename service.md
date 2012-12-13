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

## I'm noob and/or lazy

Yep, I'm lazy too. 

I may edit the gist and provide an automated way to install new services.