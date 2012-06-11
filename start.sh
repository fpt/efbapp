#!/bin/sh
cd `dirname $0`
exec erl -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -config $PWD/priv/app.config -s ssl -s reloader -s efbapp
