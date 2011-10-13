# Steps to do on releasing

1. Run `git flow release start <version>`
2. change version number in App/perlbrew.pm
3. update "Changes" file
4. review document in bin/perlbrew for obvious misdescriptions
5. Run `./dev-bin/build.sh` to build new standalone `perlbrew` executable
6. Run `shipit -n` to make sure no test failures
7. Fix test failures if any
8. Run `git flow release finish <version>`
9. Run `git checkout master`
10. Run `git push; git push --tags`
11. Run `shipit`
12. Update webpages of release note etc

