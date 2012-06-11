#!/bin/sh

cd `dirname $0`

mkdir -p lib/App

if type perlstrip >/dev/null 2>&1; then
    perlstrip -o lib/App/perlbrew.pm ../lib/App/perlbrew.pm
else
    echo "!!! perlstrip is not installed. The fatpacked executable will be really big."
fi

perl -e 'print "+++ perlbrew fatpacking with $]\n"'

export PERL5LIB="lib":$PERL5LIB

cat - <<'EOF' > perlbrew
#!/bin/sh -- # −*−perl−*−
eval 'exec perl -wS $0 ${1+"$@"}'
  if 0;
EOF

(fatpack file; cat ../bin/perlbrew) >> perlbrew

chmod +x perlbrew
mv ./perlbrew ../

echo "+++ DONE"
