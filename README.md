# R API Bindings for the Media Cloud service

`mediacloudr` seemed no longer updated and could not use the new Media Cloud API. 
So I made this package to access selected functions from the API

# Installation

Install from github 

```
remotes::install_github("vanatteveldt/rmediacloud")
```

## API Key

Make an account at Media Cloud and get an API key from [your account page](https://search.mediacloud.org/account).
It's best to put the API key in your .REnviron:

```
MEDIACLOUD_API_TOKEN=<enter the key here>
```

Alternatively, you can add it to your session each time:

```
Sys.setenv("MEDIACLOUD_API_TOKEN"="<enter the key here>")
```

# Usage

## Finding a source

To see all collections that mention 'united kingdom':
```{r}
collection_list("united kingdom")
```

To search for the source `dailymail.co.uk`:

```{r}
source_list(name="dailymail.co.uk", collection_id=34412476)
```

You can also search within a collection, e.g. the UK National sources:
```{r}
source_list(collection_id=34412476) 
```

Note: You can also find collections and sources on the [website](https://search.mediacloud.org/search), 
press 'select collections' and note the ID for the sources or collections you want.

## Getting stories

You can then search within the selected sources.
For example, this will get the first 1,000 articles from the Daily Mail that mention `immigr*`
in the first half of 2024:


```{r}
stories <- story_list(
  query="immigr*", 
  source_ids = 19142, 
  start_date=as_date("2024-01-01"), 
  end_date=as_date("2024-06-01"), 
  max_pages=1)
```

# Bonus: Getting the full text

MediaCloud only returns the title and url of each story. Using [paperboy](https://github.com/JBGruber/paperboy) 
we can attempt to get the full text:

```{r}
# remotes::install_github("JBGruber/paperboy")
texts <- head(stories$url) |> paperboy::pb_deliver(connections=1)
```

Note: This might not your depending on your source, and scraping too many articles 
from a source might not be legal and/or get your IP address banned from that site.
Use with moderation. 
