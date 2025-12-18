# Contribution

This page documents how to properly contribute to this documentation.

Our documentation uses an open source tool called
[mdbook](https://rust-lang.github.io/mdBook/). This is a lightweight
commandline tool that allows us to write almost everything in markdown with a
lot of quality of life features. If you are not familiar with this commandline
tool, I recommend downloading it and playing around with it on your own
computer. The `mdbook` command is very easy to learn. You only need to learn a
single command to start contributing to this documentation: `mdbook serve`.

`mdbook serve` creates a localhost server on port 3000 that will display your
local version of the documentation. This helps you to avoid the need to push
your update to the remote main branch everytime you make an edit to your local
repository. You will be able to see the edit immeidately showing up in your
browser if you have the the website opened.

## When to contribute

If you see typo, incorrect grammar, missing steps, or anything that you felt is
unclear to you, you should try fixing them. If you want to add new
documentation related to the DAQ server that is also a valid reason to
contribute to the DAQ server documentation.

## How to contribute

1. Clone the [documentation's Git repository](https://github.com/Highlander-Space-Program/daqserver-doc.git).
2. Edit your local repository of the documentation to whatever you want.
3. Try using the [Git commit
   convention](https://www.conventionalcommits.org/en/v1.0.0/) for your commit
   messages.
    * It's totally fine if you don't want to follow it.
4. Push the code to the remote main branch.
5. And wait. Github Action will see that the main branch is updated and run
   some scripts to automatically update the main DAQ server documentation that
   is hosted on our Github Page domain.
