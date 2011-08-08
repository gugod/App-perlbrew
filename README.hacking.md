Hi Hackers,

perlbrew is open for anyone who are willing to contribute. Here's what you do to get your work released:

- Fork the repository on github
- Modify lib/App/perlbrew.pm or bin/perlbrew, if necessary,
- Add tests
- Send a pull request to @gugod

Notice that the "master" branch is a stable branch, while the "develop" branch
is the target for pull requests. It is suggested, but not required, that you
create your own topic branch first and work on the feature, this way it makes it
a little bit easier when there are conflicts.

DO NOT edit the `./perlbrew` file directly, it is a standalone executable built
with `dev-bin/build.sh`.

Sincerely, Kang-min Liu, aka @gugod
