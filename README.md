## sklearn-build-lambda

This repo has Ansible to launch an EC2 instance, build the full scikit-learn
stack, and save a zipfile containing all the dependencies in S3. For more info
about how the script works, and how to use it, see my [blog post on deploying
sklearn to Lambda](https://serverlesscode.com/post/deploy-scikitlearn-on-lamba/)

## Building scikit-learn for Lambda

Once you run `launch_sklearner.yml` you'll have a zipfile containing sklearn
and its dependencies, to use them add your handler file to the zip, and add the
`lib` directory so it can be used for shared libs. The minimum viable sklearn
handler would thus look like:

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
