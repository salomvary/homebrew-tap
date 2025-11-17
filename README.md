# My Homebrew Tap

## How do I install these formulae?

`brew install salomvary/tap/<formula>`

Or `brew tap salomvary/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "salomvary/tap"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Available Casks

### `anyk` aka. ÁNYK aka. AbevJava aka. Általános Nyomtatványkitöltő

Cask fot the desktop app of the Hungarian National Tax and Customs Administration (NAV).

`brew install salomvary/tap/anyk`

## Development

    cd $(brew --repository salomvary/tap)
    # Make some changes

    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_FROM_API=1
    brew install anyk
    brew uninstall anyk

    brew audit --new --cask anyk
    brew style --fix anyk

    git add ...
    git commit
    git push
