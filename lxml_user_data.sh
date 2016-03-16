#!/bin/bash
set -ex
set -o pipefail

yum update -y
yum install -y \
    gcc \
    gcc-c++ \
    libxml2-devel \
    libxslt-devel \
    python27-devel

make_swap () {
    dd if=/dev/zero of=/swapfile bs=1024 count=1500000
    mkswap /swapfile
    chmod 0600 /swapfile
    swapon /swapfile
}

do_pip () {
    pip install --upgrade pip wheel
    IFS=' ' ; for pkg in lxml requests; do
        pip install --use-wheel $pkg
    done
}

strip_virtualenv () {
    echo "venv original size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python2.7/site-packages/ -name "*.so" | xargs strip
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"

    pushd $VIRTUAL_ENV/lib64/python2.7/site-packages/ && zip -r -9 -q ~/venv.zip * ; popd
    echo "site-packages compressed size $(du -sh ~/venv.zip | cut -f1)"

    pushd $VIRTUAL_ENV && zip -r -q ~/full-venv.zip * ; popd
    echo "venv compressed size $(du -sh ~/full-venv.zip | cut -f1)"
}

upload () {
    inst_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    aws s3 cp /root/venv.zip "s3://tmp.serverlesscode.com/sklearn/${inst_id}-site-pkgs.zip"
    aws s3 cp /root/full-venv.zip "s3://tmp.serverlesscode.com/sklearn/${inst_id}-full-venv.zip"
}

shared_libs () {
    libdir="$VIRTUAL_ENV/lib64/python2.7/site-packages/lib/"
    mkdir -p $VIRTUAL_ENV/lib64/python2.7/site-packages/lib || true
    cp /usr/lib64/libxslt.so.1 $libdir
    cp /usr/lib64/libexslt.so.0 $libdir
    cp /usr/lib64/libxml2.so.2 $libdir
    cp /usr/lib64/libgcrypt.so.11 $libdir
    cp /lib64/libgpg-error.so.0 $libdir
    cp /usr/lib64/liblzma.so.5 $libdir
    cp /lib64/libz.so.1 $libdir
}

main () {
    make_swap

    /usr/bin/virtualenv \
        --python /usr/bin/python lxml_build \
        --always-copy \
        --no-site-packages
    source lxml_build/bin/activate

    do_pip

    shared_libs

    strip_virtualenv

    ## done with the venv
    deactivate

    upload
}
main
