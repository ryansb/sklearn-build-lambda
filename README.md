# sklearn-build-lambda

### Building scikit-learn for AWS Lambda

This repo contains a `build.sh` script that's intended to be run in an Amazon
Linux docker container, and build scikit-learn, numpy, and scipy for use in AWS
Lambda. For more info about how the script works, and how to use it, see my
[blog post on deploying sklearn to Lambda](https://serverlesscode.com/post/scikitlearn-with-amazon-linux-container/).

There was an older version of this repo, now archived in the
[ec2-build-process](https://github.com/ryansb/sklearn-build-lambda/tree/ec2-build-process)
branch, used an EC2 instance to perform the build process and an Ansible
playbook to execute the build. That version still works, but the new dockerized
version doesn't require you to launch a remote instance.

To build the zipfile, pull the Amazon Linux image and run the build script in
it.

```
$ docker pull amazonlinux:2016.09
$ docker run -v $(pwd):/outputs -it amazonlinux:2016.09 \
      /bin/bash /outputs/build.sh
```

That will make a file called `venv.zip` in the local directory that's around
40MB.

Once you run this, you'll have a zipfile containing sklearn and its
dependencies, to use them add your handler file to the zip, and add the `lib`
directory so it can be used for shared libs. The minimum viable sklearn handler
would thus look like:

```
import os
import ctypes

for d, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.a'):
            continue
        ctypes.cdll.LoadLibrary(os.path.join(d, f))

import sklearn

def handler(event, context):
    # do sklearn stuff here
    return {'yay': 'done'}

```


## Sizing and Future Work

With just compression and stripped binaries, the full sklearn stack weighs in
at 39 MB, and could probably be reduced further by:

1. Pre-compiling all .pyc files and deleting their source
1. Removing test files
1. Removing documentation

For my purposes, 39 MB is sufficiently small, if you have any improvements to
share pull requests or issues are welcome.

## License

This project is MIT Licensed, for license info on the numpy, scipy, and sklearn
packages see their respective sites. Full text of the MIT license is in
LICENSE.txt.
