# Steps to do on releasing

1. Run `git flow release start <version>`
2. change version number in App/perlbrew.pm
3. update "Changes" file
4. Run `./dev-bin/build.sh` to build new standalone `perlbrew` executable
5. Run `mbtiny test` to make sure no test failures. Fix test failures if any.
6. Run `git flow release finish <version>`
7. Run `git checkout master`
8. Run `git push; git push --tags`
9. Run `mbtiny dist` and upload the tarball.
10. Update webpages of release note etc
