# read - fzf-based RSS feed reader

This is a shell script that pulls in the RSS feed content with [r](https://github.com/dysthesis/r), and displays the result with [fzf](https://github.com/junegunn/fzf). The user can then

- press `ENTER` to read the entry,
- press `Alt + L` to "like" an entry, or
- press `Alt + D` to "dislike" an entry.

[sim](https://github.com/dysthesis/sim) is then invoked to evaluate the similarity of the content of each entry with the liked and disliked content: the more similar an entry is to previously liked content, the higher the score, and the more similar an entry is to previously disliked content, the lower the score.

## Usage

```bash
read $FEEDS_FILE $MAX_CONCURRENT_FETCHES
```

where the `$FEEDS_FILE` is a newline-separated file listing the RSS feed URLs to fetch.
