# ChattynatorRaceIcons

[![Release](https://img.shields.io/github/v/release/Langmans/ChattynatorRaceIcons?include_prereleases&sort=semver)](https://github.com/Langmans/ChattynatorRaceIcons/releases)
[![Game Version](https://img.shields.io/badge/WoW-12.0.0-blue.svg)](https://worldofwarcraft.com)

**ChattynatorRaceIcons** is a lightweight utility for the **Chattynator** addon that adds a visual flourish to your chat logs. It automatically identifies the race and sex of players in your chat and prepends a high-quality race icon directly before their name.

***

### Key Features

*   **Visual Identity:** Instantly identify a player's race (Orc, Human, Vulpera, etc.) without needing to hover over tooltips.
*   **Seamless Integration:** Uses the Chattynator API to inject icons directly into the message stream.
*   **Dynamic Asset Loading:**
  * **Native Support:** Uses standard Blizzard Atlas icons by default.
  * **HD Visuals:** If **ElvUI\_EltreumUI** is detected, the addon automatically switches to Eltreum’s custom high-definition race textures.

***

### How it Works

The addon monitors incoming Chattynator messages. When player data is available, it generates a texture markup and anchors it to the player link. The icon is placed after the link but before the name (preserving any brackets like `[` or `]`).

### Requirements

*   **Chattynator** (Required)
*   **ElvUI\_EltreumUI** (Optional, for HD icon support)

***

### Technical Summary

*   **Performance:** Uses efficient table caching (`__index` metamethods) to ensure textures are only generated once, keeping CPU usage negligible during chat-heavy segments.
*   **Clean Injection:** Utilizes robust pattern matching to ensure icons don't break player links or clickability.
*   **Developer Friendly:** Includes built-in support for `DLAPI` debug logging.

***

> **Note:** For the best experience, ensure your Chattynator is up to date to allow proper API access for the race data modifier.

> **Note 2:** No AI was used while programming this addon. Just above description was generated.