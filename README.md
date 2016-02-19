## Building scikit-learn for Lambda

Once you run `launch_sklearner.yml` you'll have a zipfile containing sklearn
and its dependencies, to use them add your handler file to the zip, and add the
`lib` directory to the `LD_LIBRARY_PATH` like so.

```
os.environ['LD_LIBRARY_PATH'] = 'lib'
```
