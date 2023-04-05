# Diablo 2 Ressurected Multi Box

This repo is to launch mutliple copies of Diablo 2 Ressurected on your machine with minimal effort.
The goal is to farm with increased drop rate and experience.

Please note that logging in and creating/joining games takes substantial amount of time and this script will not cut this down.
It is meant to automate the boring clicking around on initial start of your farming session but for quick game changes (aka Pindle runs) it will be absolutely useless.

What this repo does:
- read config from `.config.json`
- use powershell to start D2R.exe with battlenet username/password (thus skip the super boring battlenet login process) and kill the process that it launches to prevent multile copies of D2R.exe.
- use Autoit to get to game lobby and create/join game as specified in config.

<br>

## NOTE: this code uses `handle64.exe` to kill the process that D2R.exe runs (to block mutliple copies). The executable is included in the repo for ease of use but you can remove it and copy yourself from official Microsoft download location here: https://learn.microsoft.com/en-us/sysinternals/downloads/handle

<br>

**Warning**: I cannot guarantee that AutoIt will be able to click on game buttons correctly as it depends on what resolution you run the game on.

I have tested that this works when game runs on 1920 x 1080. The reason is to be able to see multiple windows at once on one monitor.
Feel free to experiment with the mouse movements to adjust to your needs.

Also be aware that you cannot have separate settings per idling clients which join the game just to increase player count and your main battlenet client - every time you change settings all clients will use them next time they launch.

I simply start this on a spare laptop but one could play with sandboxes, virtual machines etc - I just thought it is too much effort :).

**NOTE**: there is absolutely minimal exception handling - you have been warned, if something does not work, make a PR :P I am not an AutoIt expert and whacked this in between gaming sessions, but ideally this should work no matter the game screen resolution (which I tried to achieve with relative mouse movements but to no avail).

## Required software installations:

- You need to install AutoIt (I used v3.3.14.3 at the time): https://www.autoitscript.com/site/autoit/downloads/.
- You need to have working powershell on your machine (I used 7.3 at the time): https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3.


## Prerequisites:

- create multiple battlenet accounts.
- buy multiple copies of the game, 1 per battlenet account by logging to one at a time and purchasing it for that account.
- copy game contents into a new folder, each client should have its own complete game filesystem to avoid performance issues. 
- download this repo to your machine: `git clone https://github.com/Tomasz-Kluczkowski/d2r_multibox.git`.
- create `.config.json` file in the root of the repo (it is git ignored so do not worry), see example below for its contents per battlenet account. This file will hold details of your accounts so that powershell can launch the game without Battlenet launcher and log in right away.
- configure your `idling` game clients to run on 1280 x 720 resolution with minimum details (and on a separate machine/VM/sandbox etc)

Also see `examples/.config.json`.

```json
{
    "session_details": {
        "default_game_name": "blah",
        "default_game_password": "pass"
    },
    "bnet_accounts": [
        {
        "username": "<your battlenet account username 1>",
        "password": "your battlenet account password 1",
        "d2r_path": "<path to D2R.exe for your game client 1",
        "action": "create"
    },
    {
        "username": "<your battlenet account username 2>",
        "password": "your battlenet account password 2",
        "d2r_path": "<path to D2R.exe for your game client 2",
        "action": "join"
    }
  ]
}
```

**IMPORTANT**: since you are creating a valid json structure, the backslash characters in the path have to be escaped. See example below:

```json
"d2r_path": "C:\\Program Files (x86)\\GAMES\\Diablo II Resurrected - Client1\\D2R.exe"
```

Where `action` can be:
- create, to create a game
- join, to join a game

## Launching multiple D2R.exe on your machine

Once you set everything up as in instructions above, run `D2R_Launch_All.ps1` with administrator priviledges (required for `handle64.exe` to be able to kill the process that blocks mutliple D2R.exe copies on one machine).

**NOTE**: AutoIt will be controlling your mouse and keyboard to get to lobby and create/join game for each battlenet account data present in `.config.json`.