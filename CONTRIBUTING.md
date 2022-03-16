Hi Hackers,

perlbrew is open for anyone who are willing to contribute. Here's what you do to
get your work released:

- Fork the repository on github
- Modify `lib/App/perlbrew.pm` or `script/perlbrew` if necessary.
- Add tests so others do not break your feature.
- If it seems pulsable, update `Changes` too. Put a gist of the change in the beginning of the file.
- Send a pull request to @gugod and make an offer that he cannot reject (optional :-)

Notice that the "master" branch is a stable branch, while the "develop" branch is the default target
for pull requests. The master branch should only be moved forward on CPAN releases and there
should also be a corresponding git tag for each release, which is the part only @gugod has to worry
about. It is suggested, but not required, that you create your own topic branch first and work on
the feature, this way it makes it a little bit easier when there are conflicts.

Last, DO NOT edit the `./perlbrew` file directly, it is a standalone executable
built with `dev-bin/build.sh`.

Happy hacking!

Sincerely,
Kang-min Liu, aka @gugod
