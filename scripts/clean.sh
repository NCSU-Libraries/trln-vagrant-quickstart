#!/bin/sh

rm -rf projects/trln-blacklight-quickstart
find environments/test/modules/chruby/files -name \*gz -exec rm {} \;
find environments/test/modules/chruby/files -name \*gz.asc -exec rm {} \;

