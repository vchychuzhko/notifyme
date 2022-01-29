# NotifyMe Telegram Bot Script

Shell script for Telegram bot to keep you in touch with running console commands.  

## Deploy

Create local credentials file and fill it with generated [bot API Token](https://core.telegram.org/bots#6-botfather) and [target user id](https://t.me/userinfobot):

```shell
cp .env .env.local
```

## Usage

After deploy, run your commands as:

```shell
/usr/bin/bash /path/to/notifyme/run.sh php bin/magento indexer:reindex
```

**NOTE:** To receive messages, you have to write at least one message to your bot (have chat available).

## Alias

For more comfortable usage add this line to `~/.bash_aliases` file:

```shell
alias NM="/usr/bin/bash /path/to/notifyme/run.sh"
```

**NOTE:** Do not forget to replace `/path/to/notifyme/` with your real path.

After reopening the terminal, aliased command will be available as:

```shell
NM php bin/magento indexer:reindex
```

---

**For Python implementation check [notifyme-py](https://github.com/vchychuzhko/notifyme-py/) repo**
