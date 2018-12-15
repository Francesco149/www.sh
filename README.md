http server in sh using busybox netcat

# why?
for the lulz

# is this secure?
I have no idea lmao

# usage
make sure you have busybox installed

```sh
./www.sh
```

the server should now be reachable at http://127.0.0.1:8080

to use a different port, you can run

```sh
./www.sh 8081
```

files to be served are in the ```./www``` directory

I included a sample index.ms and a date.sh cgi script

# features
## basic cgi
if a requested file is executable, it will be called with the query string
as a parameter and its output will be sent back to the client. http headers
are automatically generated

for example, if ```/scripts/foo.sh?bar=xxx&baz=yyy``` is requested and
foo.sh is executable it will be called like so

```
/scripts/foo.sh bar=xxx&baz=yyy
```

## groff support
any .ms file will be automatically converted on the fly to html. the
```-ms``` macro set is used, which also implicitly adds www macros.
see man groff_www or google it, also see man grohtml

you need to have groff installed for this to work, it should come with
the base-devel tools on most linux distros

## custom error pages
you can customize error pages for 403 and 404 by editing the 403.sh and
404.sh files

# gotchas
all executable files are considered cgi and will be executed! make sure
to chmod -x everything you don't want to run

this server doesn't send any mime type info. this means that it's up to
the browser to figure out what file type you're sending. chromium seems
to handle this well, I haven't tested on more obscure browsers
